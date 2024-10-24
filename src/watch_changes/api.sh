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
    output_changes_to_stdout "new" "Dir" "${new_dirs[@]}"
    output_changes_to_stdout "deleted" "Dir" "${deleted_dirs[@]}"
    output_changes_to_stdout "changed" "Dir" "${changed_dirs[@]}"
    output_changes_to_stdout "new" "File" "${new_files[@]}"
    output_changes_to_stdout "deleted" "File" "${deleted_files[@]}"
    output_changes_to_stdout "changed" "File" "${changed_files[@]}"

    new_or_changed_files=()
    new_or_changed_files=("${new_files[@]}" "${changed_files[@]}")

   if [ "${#new_dirs[@]}" -gt 0 ]; then
       handle_dir_changes "new" "${new_dirs[@]}"
    fi

    if [ "${#deleted_dirs[@]}" -gt 0 ]; then
       handle_dir_changes "deleted" "${deleted_dirs[@]}"
    fi

    if [ "${#changed_dirs[@]}" -gt 0 ]; then
       handle_dir_changes "changed" "${changed_dirs[@]}"
    fi

    if [ "${#new_or_changed_files[@]}" -gt 0 ]; then
       handle_file_changes "new_or_changed" "${new_or_changed_files[@]}"
    fi
 
    if [ "${#deleted_files[@]}" -gt 0 ]; then
       handle_file_changes "deleted" "${deleted_files[@]}"
    fi

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
        echo "${change_type} ${type}: ${item}"
    done
}

handle_dir_changes() {
    local type=$1
    shift
    local dirs=("$@")

    for dir in "${dirs[@]}"; do
        local relative_path=$(absolute_path_to_relative_path "$dir" "$INPUT_DIR")
        local output_dir_path="$OUTPUT_DIR/$relative_path"

        log "INFO" "Handling ${type} directory: $dir"

        if [ "$type" == "new" ]; then
            mkdir -p "$output_dir_path"
            refresh_output "$relative_path"
        elif [ "$type" == "deleted" ]; then
            log "INFO" "Removing output directory: $output_dir_path"
            rm -rf "$output_dir_path"
        elif [ "$type" == "changed" ]; then
            refresh_output "$relative_path"
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

