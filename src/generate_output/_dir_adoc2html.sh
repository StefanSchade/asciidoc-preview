#!/bin/bash

# Enable strict mode
set -euxo pipefail
IFS=$'\n\t'

dir_adoc2html() {
  # searching for directories containing *.adoc files below the current dir
  local adoc_dir_array=()
  find_adoc_dirs "$1" adoc_dir_array

  # for empty dir structure, add top level dir despite no content
  if [ ${#adoc_dir_array[@]} -eq 0 ]; then
    adoc_dir_array+=("$1")
  fi

  log "INFO" "Number of subdirectories found: ${#adoc_dir_array[@]}"
  log "INFO" "Directories that have to be processed: ${adoc_dir_array[*]}"

  for subdir in "${adoc_dir_array[@]}"; do
    log "INFO" "Processing dir $subdir"
    mkdir -p "$OUTPUT_DIR/$subdir"
    find "$INPUT_DIR/$subdir"  -name "*.adoc" | while read -r adoc_file; do
      log "INFO" "---- $adoc_file"
      (cd "$INPUT_DIR/$subdir" && asciidoctor -a toc -D "$OUTPUT_DIR/$subdir" "$adoc_file" 2>&1)
    done
  done
}

 
