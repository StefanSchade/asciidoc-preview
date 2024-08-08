#!/bin/bash

# Source necessary helper scripts
source "$SCRIPT_DIR/watch_changes/_compare_snapshots.sh"
source "$SCRIPT_DIR/watch_changes/_generate_snapshot.sh"

# Function to start watching for changes
watch_changes() {
  local old_snapshot=()
  local new_snapshot=()
  local dirs_to_handle=()

  generate_snapshot "$INPUT_DIR" old_snapshot

  while true; do
    sleep 3
    log "INFO" "watch_changes: generate new snapshot"
    generate_snapshot "$INPUT_DIR" new_snapshot

    log "INFO" "watch_changes: compare snapshots"
    compare_snapshots old_snapshot new_snapshot dirs_to_handle

    if [ ${#dirs_to_handle[@]} -ne 0 ]; then
      log "INFO" "Directories to handle: ${dirs_to_handle[*]}"
      handle_changes "${dirs_to_handle[@]}"
    else
      log "DEBUG" "No directories to handle."
    fi

    old_snapshot=("${new_snapshot[@]}")
    dirs_to_handle=()  # Reset the array for the next comparison
  done
}

# Function to handle changes by calling the appropriate function in the generate_output module
handle_changes() {
  local dirs=("$@")
  for dir in "${dirs[@]}"; do
    log "INFO" "Handling changes in directory: $dir"
    partial_refresh_output "$dir"
  done
}

