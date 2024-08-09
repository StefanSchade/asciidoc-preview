#!/bin/bash

# Source necessary helper scripts
source "$SCRIPT_DIR/watch_changes/_compare_snapshots.sh"
source "$SCRIPT_DIR/watch_changes/_generate_snapshot.sh"

# Function to start watching for changes
watch_changes() {
  local old_snapshot=()
  local new_snapshot=()

  generate_snapshot "$INPUT_DIR" old_snapshot

  while true; do
    sleep 3
    log "INFO" "watch_changes: generate new snapshot"
    generate_snapshot "$INPUT_DIR" new_snapshot

    log "INFO" "watch_changes: compare snapshots"
    local -A dirs_to_handle=()
    compare_snapshots old_snapshot new_snapshot dirs_to_handle 
   
    log "INFO" "Number of  found: ${#dirs_to_handle[@]}"
    log "DEBUG" "abcDirectories to handle after comparison: ${!dirs_to_handle[@]}"
    log "INFO" "directories that have to be processed: ${adoc_dir_array[*]}"

    # Convert keys to an indexed array
    local keys=("${!dirs_to_handle[@]}")

    log "DEBUG" "keys directly before conditional: ${keys[*]}"

    if [ ${#keys[@]} -gt 0 ]; then  # Check if there are any keys
      log "INFO" "Directories to handle: ${keys[*]}"  # Correctly log the keys
      handle_changes "${keys[@]}"  # Correctly pass the keys
    else
      log "DEBUG" "No directories to handle."
    fi

    old_snapshot=("${new_snapshot[@]}")
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
