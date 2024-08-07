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


# Get the directory of the currently executing script
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Define the input and output directories
OUTPUT_DIR=/workspace/output
INPUT_DIR=/workspace/input
LOG_DIR=/workspace/logs
LOG_FILE="$LOG_DIR/logfile.txt"

# Ensure the output directory and log directory exist
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR

# Redirect stderr to the log file
exec 2>>"$LOG_FILE"

source "$SCRIPT_DIR/helper/logger.sh"
source "$SCRIPT_DIR/helper/log_helper.sh" && log_script_name
source "$SCRIPT_DIR/generate_output/api.sh"
# source "$SCRIPT_DIR/server/api.sh"
# source "$SCRIPT_DIR/watch/api.sh"

log "INFO" "sourced scripts in $SCRIPT_DIR"

trap 'cleanup' SIGINT SIGTERM

main() {
  refresh_output "$INPUT_DIR" 
#   start_server
#   start_watching_changes
   while true; do
#     check_server_status
     sleep 1
   done
}

main

