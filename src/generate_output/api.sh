#!/bin/bash

source "$SCRIPT_DIR/generate_output/_check_dir.sh"
source "$SCRIPT_DIR/generate_output/_find_adoc_dirs.sh"
source "$SCRIPT_DIR/generate_output/_generate_index.sh"
source "$SCRIPT_DIR/helper/sanitize_path.sh"

refresh_output() {

  local relative_start_path=$1
  local absolute_input_start_path="${INPUT_DIR}/${relative_start_path}"
  local absolute_output_start_path="${OUTPUT_DIR}/${relative_start_path}"

  absolute_input_start_path=$(sanitize_path "$absolute_input_start_path")
  absolute_output_start_path=$(sanitize_path "$absolute_output_start_path")

  log "INFO" "refreshing output $relative_start_path"
  log "INFO" "absolute input start path $absolute_input_start_path"
  log "INFO" "absolute output start path $absolute_output_start_path"

  check_dir "$absolute_input_start_path" # make sure directory exits
 
  if [ -d "$absolute_output_start_path" ]; then
    # index.html will be overwritten later on - removing it here would disrupt the live update
    log "INFO" "refreshing directory $absolute_output_start_path, cleaning existing html files and subdirs"
    find_html_output=$(find "$absolute_output_start_path" -name "*.html" -not -name "index.html" -exec rm -f {} \; 2>&1)
    handle_potential_errors $? "Error during find html $find_html_output"

    ls_output=$(ls -la $absolute_output_start_path)
    log_command_output "INFO" "directory content to be cleaned $ls_output"
     
    # A find statement equivalent to the last code block
    # find_dir_output=$(find "$absolute_output_start_path" -mindepth 1 -type d -not -path "*/\.*" -exec rm -rf {} \; 2>&1)
    # results in an error. the more explicit form does not
    find_subdir_output=$(find "$absolute_output_start_path" -mindepth 1 -type d -not -path "*/\.*" -print0)
    handle_potential_errors $? "Error during find subdirs"

    # Translate null-separated to newline-separated for logging
    find_subdir_output_translated=$(echo "$find_subdir_output" | tr '\0' '\n')
    find_subdir_output_visible=$(echo "$find_subdir_output" | od -An -t x1 | tr ' ' '\n') 
    log "INFO" "find_subdir_output_visible $(find_subdir_output_visible)"
    log "INFO" "find_subdir_output $(find_subdir_output)"
    log "INFO" "find_subdir_output_translated $(find_subdir_output_translated)"
    # echo "$find_subdir_output" | while IFS= read -d $'\0' dir; do
    find "$absolute_output_start_path" -mindepth 1 -type d -not -path "*/\.*" -print0 | while IFS= read -d $'\0' dir; do
      log "INFO" "removing $dir"
      rm -rf "$dir"
      handle_potential_errors $? "Error removing directory $dir"
    done
  else
    log "INFO" "output directory $absolute_output_start_path not existing, creating new directory"
    mkdir_command_output=$(mkdir -p "$absolute_output_start_path" 2>&1)
    handle_potential_errors $? "Error creating directory $mkdir_command_output"
  fi

  # searching for directories containing *.adoc files below the current dir
  local adoc_dir_array=()
  find_adoc_dirs "$relative_start_path" adoc_dir_array
  handle_potenital_errors $? "Error finding adoc directories $relative_start_path"
  log "INFO" "Number of subdirectories found: ${#adoc_dir_array[@]}"
  log "INFO" "directories that have to be processed: ${adoc_dir_array[*]}"

  log "INFO" "Start processing list of directories with input dir $INPUT_DIR and output dir $OUTPUT_DIR"
  for subdir in "${adoc_dir_array[@]}"; do
    log "INFO" "Processing dir $subdir "
    mkdir -p "$OUTPUT_DIR/$subdir"
    find_ls_output=$(find "$INPUT_DIR/$subdir" -maxdepth 1 -name "*.adoc" -print -exec ls -l {} \; 2>&1)
    log_command_output "INFO" "$find_ls_output"
    find "$INPUT_DIR/$subdir" -maxdepth 1 -name "*.adoc" | while read -r adoc_file; do
      (cd "$INPUT_DIR/$subdir" && asciidoctor -D "$OUTPUT_DIR/$subdir" "$adoc_file" 2>&1)
    done
  done
  generate_all_indexes "$relative_start_path"
}
