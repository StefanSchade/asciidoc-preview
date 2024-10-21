#!/bin/bash

# Enable strict mode
set -euxo pipefail
IFS=$'\n\t'

dir_adoc2html() {
  local current_input_dir=$(sanitize_path "$INPUT_DIR/$1")
 
  log "INFO" "dir_adoc2html(): looking for adocs in $current_input_dir"
  # searching for directories containing *.adoc files below the current dir
  local adoc_dir_array=()
  find_adoc_dirs "$current_input_dir" adoc_dir_array

  # for empty dir structure, add top level dir despite no content
  if [ ${#adoc_dir_array[@]} -eq 0 ]; then
    adoc_dir_array+=("$1")
  fi

  log "INFO" "dir_adoc2html(): Number of subdirectories found: ${#adoc_dir_array[@]}"
  log "INFO" "dir_adoc2html(): Directories that have to be processed: $(join_by "; " "${adoc_dir_array[@]}")"

  for subdir in "${adoc_dir_array[@]}"; do
    sanitized_subdir=$(sanitize_path "$subdir")
    log "INFO" "Processing dir $subdir"
    mkdir -p "$OUTPUT_DIR/$sanitized_subdir"
    find "$INPUT_DIR/$sanitized_subdir" -maxdepth 1 -name "*.adoc" | while read -r adoc_file; do
      log "INFO" "---- $adoc_file"
      (cd "$INPUT_DIR/$sanitized_subdir" && asciidoctor -a toc -D "$OUTPUT_DIR/$sanitized_subdir" "$adoc_file" 2>&1)
    done
  done
}

 
