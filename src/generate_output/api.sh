#!/bin/bash

# Enable strict mode
set -euxo pipefail
IFS=$'\n\t'

source "$SCRIPT_DIR/helper/_join_by.sh"
source "$SCRIPT_DIR/helper/files/_sanitize_path.sh"
source "$SCRIPT_DIR/helper/files/_check_existence.sh"
source "$SCRIPT_DIR/generate_output/_dir_adoc2html.sh"
source "$SCRIPT_DIR/generate_output/_generate_index.sh"
source "$SCRIPT_DIR/generate_output/_find_adoc_dirs.sh"
source "$SCRIPT_DIR/generate_output/_clean_old_html.sh"
source "$SCRIPT_DIR/generate_output/_clean_old_dirs.sh"
source "$SCRIPT_DIR/helper/absolute_path_to_relative_path.sh"

refresh_output() {

  local relative_start_path=$(sanitize_path "$1")
  local absolute_input_start_path="${INPUT_DIR}/${relative_start_path}"
  local absolute_output_start_path="${OUTPUT_DIR}/${relative_start_path}"
  log "DEBUG" "hallo"
  absolute_input_start_path=$(sanitize_path "$absolute_input_start_path")
  absolute_output_start_path=$(sanitize_path "$absolute_output_start_path")

  log "INFO" "refresh_output(): relative_start_path=$relative_start_path"
  log "INFO" "refresh_output(): absolute_input_start_path=$absolute_input_start_path"
  log "INFO" "refresh_output(): absolute_output_start_path=$absolute_output_start_path"

  assert_dir "$absolute_input_start_path"

  if [ -d "$absolute_output_start_path" ]; then
    log "INFO" "refresh_output(): dir $absolute_output_start_path exists, cleaning outdated content"
    clean_old_files "$absolute_output_start_path"
    clean_old_dirs "$absolute_output_start_path"
  else
    log "INFO" "refresh_otput(): dir $absolute_output_start_path not existing, creating new directory"
    mkdir_command_output=$(mkdir -p "$absolute_output_start_path" 2>&1)
  fi

  log "INFO" "refresh_output(): transform adocs to html"
  dir_adoc2html "$relative_start_path"

  log "INFO" "refresh_output(): generate index.html for each dir"
  generate_all_indexes "$relative_start_path"
}
