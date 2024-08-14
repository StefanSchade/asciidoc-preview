#!/bin/bash

# author: Stefan Schade
#
# description:
# starts the asciidoc-preview by performing these 3 tasks 
# 1. scan INPUT_DIR for asciidoc files (*.adoc), transform them into
#    html and replicate the input structure in OUTPUT_DIR
# 2. setting up a local web server that serves the html files to
#    localhost:4000. This server will refresh in case the html changes
# 3. watch the INPUT_DIR for changes to the asciidoc files or directories
#    and update the html.

LOG_LEVEL=DEBUG

# Get the directory of the currently executing script
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Define the input apind output directories
OUTPUT_DIR=/workspace/output
INPUT_DIR=/workspace/input
LOG_DIR=/workspace/logs
LOG_FILE="$LOG_DIR/logfile.txt"

mkdir -p "$OUTPUT_DIR"
mkdir -p "$LOG_DIR"
touch "$LOG_FILE"

source "$SCRIPT_DIR/helper/log_script_name.sh" && log_script_name
source "$SCRIPT_DIR/helper/cleanup.sh"
source "$SCRIPT_DIR/generate_output/api.sh"
source "$SCRIPT_DIR/livereloadx_server/api.sh"
source "$SCRIPT_DIR/watch_changes/api.sh"

log "INFO" "running script in directory $(pwd)"
log "INFO" "sourced scripts in $SCRIPT_DIR"

trap 'cleanup' SIGINT SIGTERM

main() {

  # initially process the whole input directory
  # by using a path relative to the INPUT_DIR
  refresh_output "."
  
  start_server 

  watch_changes &
  WATCH_PID=$!

  # Wait for background processes
  wait $WATCH_PID
  wait $LIVERELOAD_PID 

}

main

