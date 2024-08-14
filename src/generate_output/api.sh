#!/bin/bash

source "$SCRIPT_DIR/generate_output/_check_dir.sh"
source "$SCRIPT_DIR/generate_output/_find_adoc_dirs.sh"
source "$SCRIPT_DIR/generate_output/_generate_index.sh"


sanitize_path() {
    local path=$1
    # Remove trailing /. or /./
    path="${path%.}"
    path="${path%./}"
    echo "$path"
}


refresh_output() {

  local relative_start_path=$1
  local absolute_input_start_path="${INPUT_DIR}/${relative_start_path}"
  local absolute_output_start_path="${OUTPUT_DIR}/${relative_start_path}"

  absolute_input_start_path=$(sanitize_path "$absolute_input_start_path")
  absolute_output_start_path=$(sanitize_path "$absolute_output_start_path")

  log "INFO" "Absolute input start path $absolute_input_start_path"
  log "INFO" "Absolute output start path $absolute_output_start_path"

  check_dir "$absolute_input_start_path" # make sure directory exits
  
#  log "INFO" "cleaning directory $absolute_output_start_path of previous files..." 
#  if [ -d "$absolute_output_start_path" ]; then
#    log "INFO" "Directory $absolute_output_start_path exists - proceeding to remove contents"
#    ls_output=$(ls -la "$absolute_output_start_path")
#    log_command_output "INFO" "$ls_output"
#    rm_output=$(rm -rf "$absolute_output_start_path" 2>&1)
#    log_command_output "INFO" "$rm_output"
#  fi
  
  # It turns out the output path sometimes can not be removed completely - in this case we
  # remove the contents file by file and subdir by subdir
  if [ -d "$absolute_output_start_path" ]; then
    log "INFO" "refreshing directory $absolute_output_start_path, cleaning html files and subdirs"
    find_html_output=$(find "$absolute_output_start_path" -name "*.html" -not -name "index.html" -exec rm -f {} \; 2>&1)
    log_command_output "INFO" "find html $find_html_output"
    find_dir_output=$(find "$absolute_output_start_path" -mindepth 1 -type d -not -path "*/\.*" -exec rm -rf {} \; 2>&1)
    log_command_output "INFO" "find dirs $find_dir_output"
 else
    log "INFO" "Successfully removed $absolute_output_start_path - replace it by a fresh directory"
    mkdir -p "$absolute_output_start_path"
  fi


  local adoc_dir_array=()
  find_adoc_dirs "$relative_start_path" adoc_dir_array
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
