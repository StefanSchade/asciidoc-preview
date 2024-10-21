#!/bin/bash

# Enable strict mode
set -euxo pipefail
IFS=$'\n\t'

# Source necessary helper scripts
source "$SCRIPT_DIR/watch_changes/_compare_snapshots.sh"
source "$SCRIPT_DIR/watch_changes/_generate_snapshot.sh"
source "$SCRIPT_DIR/helper/absolute_path_to_relative_path.sh"
source "$SCRIPT_DIR/generate_output/_generate_index.sh"

watch_changes() {
  local old_snapshot=()
  local new_snapshot=()

  generate_snapshot "$INPUT_DIR" old_snapshot

  while true; do
    sleep 5
    log "INFO" "watch_changes/api.sh: generate new snapshot"
    generate_snapshot "$INPUT_DIR" new_snapshot

    log "INFO" "watch_changes/api.sh: compare snapshots"
    local new_dirs=() deleted_dirs=() changed_dirs=()
    local new_files=() deleted_files=() changed_files=()

    # Pass snapshots correctly to avoid circular reference
    compare_snapshots old_snapshot new_snapshot new_dirs deleted_dirs changed_dirs new_files deleted_files changed_files

    # Output categorized changes to stdout
    output_changes_to_stdout "${new_dirs[@]}" "Dir" "new"
    output_changes_to_stdout "${deleted_dirs[@]}" "Dir" "deleted"
    output_changes_to_stdout "${changed_dirs[@]}" "Dir" "changed"
    output_changes_to_stdout "${new_files[@]}" "File" "new"
    output_changes_to_stdout "${deleted_files[@]}" "File" "deleted"
    output_changes_to_stdout "${changed_files[@]}" "File" "changed"

    new_or_changed_files=()
    new_or_changed_files=("${new_files[@]}" "${changed_files[@]}")

   if [ "${#new_dirs[@]}" -gt 0 ]; then
       handle_dir_changes "${new_dirs[@]}" "new"
    fi

    if [ "${#deleted_dirs[@]}" -gt 0 ]; then
       handle_dir_changes "${deleted_dirs[@]}" "deleted"
    fi

    if [ "${#changed_dirs[@]}" -gt 0 ]; then
       handle_dir_changes "${changed_dirs[@]}" "changed"
    fi

    if [ "${#new_or_changed_files[@]}" -gt 0 ]; then
       handle_file_changes "${new_or_changed_files[@]}" "new or changed"
    fi
 
    if [ "${#deleted_files[@]}" -gt 0 ]; then
       handle_file_changes "${deleted_files[@]}" "deleted"
    fi

    old_snapshot=("${new_snapshot[@]}")
  done
}

# Function to output changes to stdout in a nice format
output_changes_to_stdout() {
  local items=("$@")
  
  local type=${2:-"UnknownType"}
  local change_type=${3:-"UnknownChangeType"}

  # Output each item
  for item in "${items[@]}"; do
    echo "$type $change_type: $item"
  done
}


handle_dir_changes() {
  local -n dirs=$1  # Pass array by reference
  local type=$2
  for dir in "${dirs[@]}"; do
    relative_path=$(absolute_path_to_relative_path "$dir" "$INPUT_DIR")
    local output_dir_path="${OUTPUT_DIR}/${relative_path}"
    log "INFO" "Handling $type directory: $dir"
    if [ "$type" == "new" ]; then
      mkdir -p "$output_dir_path"
      generate_index "$output_dir_path"
      # refresh_output "$relative_path"
    elif [ "$type" == "deleted" ]; then
      log "INFO" "Removing output directory: $output_dir_path"
      rm -rf "$output_dir_path"
    elif [ "$type" == "changed" ]; then
       generate_index "$output_dir_path"
      # refresh_output "$relative_path"
    fi
  done
}

handle_file_changes() {
  local -n files=$1  # Pass array by reference
  local type=$2
  for file in "${files[@]}"; do
    log "INFO" "handle_file_changes: $type $file"
    local relative_path=$(absolute_path_to_relative_path "$file" "$INPUT_DIR")
    local html_file="${OUTPUT_DIR}/${relative_path%.adoc}.html"
    if [ "$type" == "new_or_changed" ]; then
      asciidoctor -a toc -D "$(dirname "$html_file")" "$file"
    elif [ "$type" == "deleted" ]; then
      log "INFO" "Removing output file: $html_file" 
      rm -f "$html_file"
     fi
  done
}

