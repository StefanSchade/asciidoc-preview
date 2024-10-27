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
    log "INFO" "watch_changes/api.sh(): generate new snapshot"
    generate_snapshot "$INPUT_DIR" new_snapshot

    log "INFO" "watch_changes/api.sh(): compare snapshots"
    local new_dirs=() deleted_dirs=() changed_dirs=()
    local new_files=() deleted_files=() changed_files=()

    # Pass snapshots correctly to avoid circular reference
    compare_snapshots old_snapshot new_snapshot new_dirs deleted_dirs changed_dirs new_files deleted_files changed_files

    # Output categorized changes to stdout
    log "INFO" "watch_changes/api.sh(): new directories"
    output_changes_to_stdout "new" "Dir" "${new_dirs[@]}"

    log "INFO" "watch_changes/api.sh(): deleted directories"
    output_changes_to_stdout "deleted" "Dir" "${deleted_dirs[@]}"
    
    log "INFO" "watch_changes/api.sh(): changed directories"
    output_changes_to_stdout "changed" "Dir" "${changed_dirs[@]}"
    
    log "INFO" "watch_changes/api.sh(): new files"
    output_changes_to_stdout "new" "File" "${new_files[@]}"
    
    log "INFO" "watch_changes/api.sh(): deleted files"
    output_changes_to_stdout "deleted" "File" "${deleted_files[@]}"
    
    log "INFO" "watch_changes/api.sh(): changed files"
    output_changes_to_stdout "changed" "File" "${changed_files[@]}"

    new_or_changed_files=()
    new_or_changed_files=("${new_files[@]}" "${changed_files[@]}")

    new_or_changed_dirs=()
    new_or_changed_dirs=("${new_dirs[@]}" "${changed_dirs[@]}")

    # create new directories
    for dir in "${new_dirs[@]}"; do
        local relative_path=$(absolute_path_to_relative_path "$dir" "$INPUT_DIR")
        local output_dir_path="$OUTPUT_DIR$relative_path"
        log "INFO" "watch_changes(): creating new output dir $output_dir_path"
        mkdir -p "$output_dir_path" 
    done

    # (re) create html for new and changed adoc files
    for file in "${new_or_changed_files[@]}"; do
      local relative_path=$(absolute_path_to_relative_path "$file" "$INPUT_DIR")
      local html_file="${OUTPUT_DIR}${relative_path%.adoc}.html"
      log "INFO" "watch_changes(): generating html for asciidoc file $html_file"
      asciidoctor -a toc -D "$(dirname "$html_file")" "$file"
    done

    # delete html for removed adoc files
    for file in "${deleted_files[@]}"; do
      local relative_path=$(absolute_path_to_relative_path "$file" "$INPUT_DIR")
      local html_file="${OUTPUT_DIR}${relative_path%.adoc}.html"
      log "INFO" "watch_changes(): removing html for deleted asciidoc file $html_file"
      rm -f $html_file
     done

    # delete removed directories
    for dir in "${deleted_dirs[@]}"; do
        local relative_path=$(absolute_path_to_relative_path "$dir" "$INPUT_DIR")
        local output_dir_path="$OUTPUT_DIR$relative_path"
        log "INFO" "watch_changes(): removing output dir $output_dir_path"
        rm -rf "$output_dir_path" 
    done

    # create new index.html files for all new or changed directories
    for dir in "${new_or_changed_dirs[@]}"; do
        local relative_path=$(absolute_path_to_relative_path "$dir" "$INPUT_DIR")
        local output_dir_path="$OUTPUT_DIR$relative_path"
        log "INFO" "watch_changes(): creating or updating index file for dir $output_dir_path"
        generate_index $output_dir_path
    done


    old_snapshot=("${new_snapshot[@]}")
  done
}

# Function to output changes to stdout in a nice format
output_changes_to_stdout() {
    local change_type=$1
    local type=$2
    shift 2
    local items=("$@")

    for item in "${items[@]}"; do
        log "output_changes_to_stdout(): ${change_type} | ${type}: ${item} "
        echo "${change_type} ${type}: ${item}"
    done
}

