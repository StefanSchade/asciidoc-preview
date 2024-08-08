#!/bin/bash

source "$SCRIPT_DIR/livereloadx_server/_check_server_status.sh"

start_server() {
  cd "$OUTPUT_DIR"
  log "INFO" "Current working directory before starting livereloadx: $(pwd)"
  log "INFO" "starting livereloadx server..."
  livereloadx -s . -p 4000 --verbose &

  LIVERELOAD_PID=$!

  # Wait for livereloadx to start
  sleep 5

  check_server_status

  # Adding a test request to see if the livereloadx server is responding correctly
  curl -I http://localhost:4000

  # Exporting the PID to be used in cleanup
  export LIVERELOAD_PID
}
