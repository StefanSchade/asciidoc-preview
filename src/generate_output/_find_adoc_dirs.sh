#!/bin/bash

find_adoc_dirs() {
  local relative_start_path="$1"
  local absolute_input_start_path="${INPUT_DIR}/${relative_start_path}"
  local -n adoc_dirs_ref=$2  # Use nameref to pass the array by reference

  log "INFO" "Searching for adocs in $absolute_input_start_path"
  
  # Always include the start dir even if there is no adoc at all
  adoc_dirs_ref+=("$relative_start_path")

  # Capture the list of directories in a variable
  local subdirs
  subdirs=$(find "$absolute_input_start_path" -type d)

  # Iterate over the captured directories
  while IFS= read -r subdir; do
    echo "Checking subdir: $subdir" >&2
    if [[ "$subdir" != "$absolute_input_start_path" && \
          "$subdir" != "$absolute_input_start_path/.." && \
          "$subdir" != "$absolute_input_start_path/." ]]; then
      if find "$subdir" -maxdepth 1 -name "*.adoc" | read -r; then
        relative_subdir="${subdir#$INPUT_DIR/}" # Remove base path
        log "INFO" "Found .adoc in: $relative_subdir"
        adoc_dirs_ref+=("$relative_subdir")
      fi
    fi
  done <<< "$subdirs"
}
