#!/bin/bash

source "$SCRIPT_DIR/generate_output/_check_dir.sh"
source "$SCRIPT_DIR/generate_output/_find_adoc_dirs.sh"
source "$SCRIPT_DIR/generate_output/_generate_index.sh"

refresh_output() {

  local relative_start_path=$1
  local absolute_input_start_path="${INPUT_DIR}/${relative_start_path}"
  local absolute_output_start_path="${OUTPUT_DIR}/${relative_start_path}"

  echo "Current working directory $(pwd)" >&2
  echo "Absolute input start path $absolute_input_start_path" >&2
  echo "Absolute output start path $absolute_output_start_path" >&2

  check_dir "$absolute_input_start_path" # make sure directory exits
  
  log "INFO" "cleaning directory $absolute_output_start_path of previous files..."
  cd /workspace
  
  if [ -d "$absolute_output_start_path" ]; then
    log "INFO" "Directory $absolute_output_start_path exists before removal. Contents:"
    ls -la "$absolute_output_start_path"
  fi
  
  rm -rf "$absolute_output_start_path"

  if [ -d "$absolute_output_start_path" ]; then
    log "ERROR" "Failed to remove $absolute_output_start_path"
  else
    log "INFO" "Successfully removed $absolute_output_start_path"
  fi

  mkdir -p "$absolute_output_start_path"

  local adoc_dir_array=()
  find_adoc_dirs "$relative_start_path" adoc_dir_array
  log "INFO" "Number of subdirectories found: ${#adoc_dir_array[@]}"
  log "INFO" "directories that have to be processed: ${adoc_dir_array[*]}"

  log "INFO" "Start processing list of directories with input dir $INPUT_DIR and output dir $OUTPUT_DIR"
  for subdir in "${adoc_dir_array[@]}"; do
    log "INFO" "Processing dir $subdir "
    mkdir -p "$OUTPUT_DIR/$subdir"
    find "$INPUT_DIR/$subdir" -maxdepth 1 -name "*.adoc" -print -exec ls -l {} \;
    find "$INPUT_DIR/$subdir" -maxdepth 1 -name "*.adoc" -exec asciidoctor -D "$OUTPUT_DIR/$subdir" {} \;
  done
  generate_all_indexes "$relative_start_path"
}
