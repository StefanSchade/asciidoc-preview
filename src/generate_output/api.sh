#!/bin/bash

# Enable strict mode
set -euxo pipefail
IFS=$'\n\t'

source "$SCRIPT_DIR/generate_output/_check_dir.sh"
source "$SCRIPT_DIR/generate_output/_find_adoc_dirs.sh"
source "$SCRIPT_DIR/generate_output/_generate_index.sh"
source "$SCRIPT_DIR/helper/sanitize_path.sh"
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

  if check_dir "$absolute_input_start_path"; then
    log " INFO" "input dir is existing"
  else
    log "ERROR" "input dir is not existing"
    exit 1
  fi


  if [ -d "$absolute_output_start_path" ]; then
    log "INFO" "refreshing directory $absolute_output_start_path, cleaning existing html files and subdirs"
    # index.html of the start dir excluded as it will be overwritten later - removing it early would disturb the live update
    find_html_output=$(find "$absolute_output_start_path" -name "*.html" -not -name "index.html" -exec rm -f {} \; 2>&1)
    if [[ $? -ne 0 ]]; then
       log "ERROR" "no file found in ${absolute_output_start_path}, but that is not an error"
    fi

    # remove later as this did just contribute to the debugging durign development
    ls_output=$(ls -la "$absolute_output_start_path" 2>&1)
    if [[ $? -eq 0 ]]; then
       log "INFO" "directory content: $ls_output"
    else
       log "ERROR" "Error listening directory content: $ls_output"
    fi

    # find_dir_output=$(find "$absolute_output_start_path" -mindepth 1 -type d -not -path "*/\.*" -exec rm -rf {} \; 2>&1)
    # results in an error as the parent directory might already have been removed before. therefore we switch to this form
    find "$absolute_output_start_path" -mindepth 1 -type d -not -path "*/\.*" -print0 | tr '\0' '\n' | while IFS= read -d $'\n' outdir; do
      if [ -n "$outdir" ]; then  # Add a check to ensure $dir is not empty
         relative_output_path=$(output_path_to_relative_path "$outdir")
         if [ -n "$relative_output_path" ]; then
            indir="${INPUT_DIR}/$relative_output_path"
         else
            log "ERROR" "Could not determine relative output path for $outdir"
            exit 1
         fi
            log "INFO" "checking if directory $indir should be removed"
         if check_dir "$indir"; then
            log "INFO" "directory $indir exists - skip removal of $outdir"
         else
            log "INFO" "directory $indir does not exist anymore - removing $outdir"
            rm -rf "$outdir"
         fi
      fi
    done
  else
    log "INFO" "output directory $absolute_output_start_path not existing, creating new directory"
    mkdir_command_output=$(mkdir -p "$absolute_output_start_path" 2>&1)
  fi

  # searching for directories containing *.adoc files below the current dir
  local adoc_dir_array=()
  find_adoc_dirs "$relative_start_path" adoc_dir_array
  log "INFO" "Number of subdirectories found: ${#adoc_dir_array[@]}"
  log "INFO" "directories that have to be processed: ${adoc_dir_array[*]}"

  log "INFO" "Start processing list of directories with input dir $INPUT_DIR and output dir $OUTPUT_DIR"
  for subdir in "${adoc_dir_array[@]}"; do
    log "INFO" "Processing dir $subdir "
    mkdir -p "$OUTPUT_DIR/$subdir"
    find "$INPUT_DIR/$subdir" -maxdepth 1 -name "*.adoc" | while read -r adoc_file; do
      (cd "$INPUT_DIR/$subdir" && asciidoctor -a toc -D "$OUTPUT_DIR/$subdir" "$adoc_file" 2>&1)
    done
  done
  generate_all_indexes "$relative_start_path"
}
