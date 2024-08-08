#!/bin/bash

source "$SCRIPT_DIR/generate_output/_check_dir.sh"
source "$SCRIPT_DIR/generate_output/_find_adoc_dirs.sh"
source "$SCRIPT_DIR/generate_output/_generate_index.sh"

refresh_output() {

  local relative_start_path=$1
  local absolute_input_start_path="${INPUT_DIR}/${relative_start_path}"
  local absolute_output_start_path="${OUTPUT_DIR}/${relative_start_path}"

  check_dir "$absolute_input_start_path" # make sure directory exits
  
  log "INFO" "cleaning directory $absolute_output_start_path of previous files..."
  rm -rf "$absolute_output_start_path"
  mkdir -p "$absolute_output_start_path"

  local adoc_dir_array=()
  find_adoc_dirs "$relative_start_path" adoc_dir_array
  log "INFO" "Number of subdirectories found: ${#adoc_dir_array[@]}"
  log "INFO" "directories that have to be processed: ${adoc_dir_array[*]}"

  log "INFO" "Start processing list of directories with input dir $INPUT_DIR and output dir $OUTPUT_DIR"
  for subdir in "${adoc_dir_array[@]}"; do
    log "INFO" "Processing dir $subdir "
    mkdir -p "$OUTPUT_DIR/$subdir"
    find "$INPUT_DIR/$subdir" -maxdepth 1 -name "*.adoc" -exec asciidoctor -D "$OUTPUT_DIR/$subdir" {} \;
  done
  generate_all_indexes "$relative_start_path"
}
