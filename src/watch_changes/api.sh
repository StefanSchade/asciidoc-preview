#!/bin/bash

# Enable strict mode
set -euxo pipefail
IFS=$'\n\t'

# Source necessary helper scripts
source "$SCRIPT_DIR/watch_changes/_compare_snapshots.sh"
source "$SCRIPT_DIR/watch_changes/_generate_snapshot.sh"
source "$SCRIPT_DIR/helper/absolute_path_to_relative_path.sh"


watch_changes() {
  local old_snapshot=()
  local new_snapshot=()

  generate_snapshot "$INPUT_DIR" old_snapshot

  while true; do
    sleep 5
    log "INFO" "watch_changes: generate new snapshot"
    generate_snapshot "$INPUT_DIR" new_snapshot

    log "INFO" "watch_changes: compare snapshots"
    local dirs_to_handle=()
    local files_to_handle=()
    
    compare_snapshots old_snapshot new_snapshot dirs_to_handle files_to_handle 

    log "INFO" "Directories to handle: ${dirs_to_handle[*]}"
    log "INFO" "Files to handle: ${files_to_handle[*]}"

    if [ ${#dirs_to_handle[@]} -gt 0 ]; then
      handle_dir_changes "${dirs_to_handle[@]}"
    fi

    if [ ${#files_to_handle[@]} -gt 0 ]; then
      handle_file_changes "${files_to_handle[@]}"
    fi

    old_snapshot=("${new_snapshot[@]}")
  done
}

handle_dir_changes() {
  local dirs=("$@")
  for dir in "${dirs[@]}"; do
    log "INFO" "Handling changes in directory: $dir"
    relative_path=$(absolute_path_to_relative_path "$dir" "$INPUT_DIR")
    if [ -n "$relative_path" ]; then
      refresh_output "$relative_path"
    else
      log "ERROR" "Could not determine relative path for $dir, skipping."
    fi
  done
}

handle_file_changes() {
  local files=("$@")
  for file in "${files[@]}"; do
    log "INFO" "Handling file change: $file"

    # Get the relative path of the file
    local relative_path=$(absolute_path_to_relative_path "$file" "$INPUT_DIR")
    local html_file="${OUTPUT_DIR}/${relative_path%.adoc}.html"

    if [ -f "$file" ]; then
      # If the .adoc file exists, regenerate the corresponding .html
      log "INFO" "Re-generating HTML for $file"
      asciidoctor -a toc -D "$(dirname "$html_file")" "$file"
    else
      # If the .adoc file was deleted, remove the corresponding .html file
      log "INFO" "Removing HTML for deleted file: $html_file"
      rm -f "$html_file"
    fi
  done
}


# Adjust this function to only remove files where the corresponding .adoc has been deleted

clean_output_directory() {
  local output_dir="$1"

  find "$output_dir" -name "*.html" | while read -r html_file; do
    local adoc_file="${INPUT_DIR}/${html_file%.html}.adoc"

    if [ ! -f "$adoc_file" ]; then
      log "INFO" "Removing orphaned HTML file: $html_file"
      rm -f "$html_file"
    fi
  done
}

