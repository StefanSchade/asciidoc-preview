#!/bin/bash

# Enable strict mode
set -euxo pipefail
IFS=$'\n\t'

clean_old_files() {
  log "INFO" "clean htmls, where adoc does not exist from dir $1"
  find "$1" -name "*.html" -not -name "index.html" | while IFS= read -r html_file; do
    relative_html_path=$(output_path_to_relative_path "$html_file")
    input_file="${INPUT_DIR}/${relative_html_path%.html}.adoc"
    if check_file "$input_file"; then
        log "DEBUG" "$input_file exists - keep $html_file"
    else
        log "DEBUG" "$input_file does not exist anymore - removing $html_file"
        rm -f "$html_file"
    fi
  done
}
 
