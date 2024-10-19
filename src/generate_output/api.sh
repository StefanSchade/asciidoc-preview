#!/bin/bash

# Enable strict mode
set -euxo pipefail
IFS=$'\n\t'

source "$SCRIPT_DIR/helper/files/_sanitize_path.sh"
source "$SCRIPT_DIR/helper/files/_check_existence.sh"
source "$SCRIPT_DIR/generate_output/_generate_index.sh"
source "$SCRIPT_DIR/generate_output/_find_adoc_dirs.sh"
source "$SCRIPT_DIR/generate_output/_clean_old_html.sh"
source "$SCRIPT_DIR/generate_output/_clean_old_dirs.sh"
source "$SCRIPT_DIR/helper/absolute_path_to_relative_path.sh"

refresh_output() {

  log "INFO" "inside refresh output"

  local relative_start_path=$1
  local absolute_input_start_path="${INPUT_DIR}/${relative_start_path}"
  local absolute_output_start_path="${OUTPUT_DIR}/${relative_start_path}"

  absolute_input_start_path=$(sanitize_path "$absolute_input_start_path")
  absolute_output_start_path=$(sanitize_path "$absolute_output_start_path")

  log "INFO" "refreshing output $relative_start_path"
  log "INFO" "absolute input start path $absolute_input_start_path"
  log "INFO" "absolute output start path $absolute_output_start_path"

  assert_dir "$absolute_input_start_path"

  if [ -d "$absolute_output_start_path" ]; then
    clean_old_files "$absolute_output_start_path"
    clean_old_dirs "$absolute_output_start_path"
  else
    log "INFO" "output directory $absolute_output_start_path not existing, creating new directory"
    mkdir_command_output=$(mkdir -p "$absolute_output_start_path" 2>&1)
  fi

  # searching for directories containing *.adoc files below the current dir
  local adoc_dir_array=()
  find_adoc_dirs "$relative_start_path" adoc_dir_array

  # for empty dir structure, add top level dir despite no content
  if [ ${#adoc_dir_array[@]} -eq 0 ]; then
    adoc_dir_array+=("$relative_start_path")
  fi

  log "INFO" "Number of subdirectories found: ${#adoc_dir_array[@]}"
  log "INFO" "Directories that have to be processed: ${adoc_dir_array[*]}"

  log "INFO" "Start processing list of directories with input dir $INPUT_DIR and output dir $OUTPUT_DIR"
  for subdir in "${adoc_dir_array[@]}"; do
    log "INFO" "Processing dir $subdir"
    mkdir -p "$OUTPUT_DIR/$subdir"
    find "$INPUT_DIR/$subdir"  -name "*.adoc" | while read -r adoc_file; do
      log "INFO" "---- $adoc_file"
      (cd "$INPUT_DIR/$subdir" && asciidoctor -a toc -D "$OUTPUT_DIR/$subdir" "$adoc_file" 2>&1)
    done
  done

  # Generate index for all directories
  generate_all_indexes "$relative_start_path"
}
