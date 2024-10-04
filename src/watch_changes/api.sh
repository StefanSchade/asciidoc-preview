#!/bin/bash

# Enable strict mode
set -euxo pipefail
IFS=$'\n\t'

# Source necessary helper scripts
source "$SCRIPT_DIR/watch_changes/_compare_snapshots.sh"
source "$SCRIPT_DIR/watch_changes/_generate_snapshot.sh"
source "$SCRIPT_DIR/helper/absolute_path_to_relative_path.sh"

# Function to start watching for changes
watch_changes() {
  local old_snapshot=()
  local new_snapshot=()

  generate_snapshot "$INPUT_DIR" old_snapshot

  while true; do
    sleep 5
    log "INFO" "watch_changes: generate new snapshot"
    generate_snapshot "$INPUT_DIR" new_snapshot

    log "INFO" "watch_changes: compare snapshots"
    local dirs_to_handle=()
    compare_snapshots old_snapshot new_snapshot dirs_to_handle 

    log "INFO" "Number of directories found: ${#dirs_to_handle[@]}"
    log "DEBUG" "Directories to handle after comparison: ${dirs_to_handle[*]}"


    if [ ${#dirs_to_handle[@]} -gt 0 ]; then  # Check if there are any keys
      log "INFO" "Directories to handle: ${dirs_to_handle[*]}"  # Correctly log the keys
      handle_changes "${dirs_to_handle[@]}"  # Correctly pass the keys
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
    relative_path=$(absolute_path_to_relative_path "$dir" "$INPUT_DIR")
    if [ -n "$relative_path" ]; then
      refresh_output "$relative_path"  # Refresh only the specific directory
    else
      log "ERROR" "Could not determine relative path for $dir, skipping."
    fi
  done
    # refresh_output $(input_path_to_relative_path "$absolute_path")
    # to simplify the algorithm any change will lead to a complete refresh
    # unless I discover problems using the tool simplicity seems more
    # important than efficiency
  #  refresh_output . 
  #done
}

