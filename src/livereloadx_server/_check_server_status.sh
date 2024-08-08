#!/bin/bash

check_server_status() {
  if ps -p $LIVERELOAD_PID > /dev/null; then
    log "INFO" "livereloadx started successfully."
  else
    echo "Error: livereloadx failed to start."
    exit 1
  fi
}
