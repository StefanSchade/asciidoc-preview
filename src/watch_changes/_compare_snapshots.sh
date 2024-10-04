#!/bin/bash

# Enable strict mode
set -euxo pipefail
IFS=$'\n\t'

compare_snapshots() {
  local -n old_snap=$1
  local -n new_snap=$2
  local -n dirs_to_handle_ref=$3
  local -n files_to_handle_ref=$4
  local -A unique_dirs=()
  local -A unique_files=()

  local old_dirs=$(printf "%s\n" "${old_snap[@]}" | grep '^D' | sort)
  local new_dirs=$(printf "%s\n" "${new_snap[@]}" | grep '^D' | sort)
  local old_files=$(printf "%s\n" "${old_snap[@]}" | grep '^F' | sort)
  local new_files=$(printf "%s\n" "${new_snap[@]}" | grep '^F' | sort)

  log "DEBUG" "Old Dirs: $old_dirs"
  log "DEBUG" "New Dirs: $new_dirs"
  log "DEBUG" "Old Files: $old_files"
  log "DEBUG" "New Files: $new_files"

  # Check for removed directories
  comm -23 <(echo "$old_dirs") <(echo "$new_dirs") | while read -r line; do
    log "DEBUG" "Found removed directory: $line"
    unique_dirs["$(dirname "$(echo "$line" | cut -d' ' -f3-)")"]=1
  done

  # Check for added directories
  comm -13 <(echo "$old_dirs") <(echo "$new_dirs") | while read -r line; do
    log "DEBUG" "Found added directory: $line"
    unique_dirs["$(dirname "$(echo "$line" | cut -d' ' -f3-)")"]=1
  done

  # Check for removed files
  comm -23 <(echo "$old_files") <(echo "$new_files") | while read -r line; do
    log "DEBUG" "Found removed file: $line"
    unique_files["$(echo "$line" | cut -d' ' -f3-)"]=1  # Track file changes separately
  done

  # Check for added files
  comm -13 <(echo "$old_files") <(echo "$new_files") | while read -r line; do
    log "DEBUG" "Found added file: $line"
    unique_files["$(echo "$line" | cut -d' ' -f3-)"]=1  # Track file changes separately
  done

  # Check for timestamp change to differentiate between new/delete/move - irrelevant for our algorithm
  while read -r old_line; do
    local old_timestamp=$(echo "$old_line" | cut -d' ' -f2)
    local old_dirname=$(echo "$old_line" | cut -d' ' -f3-)
    local new_line=$(echo "$new_dirs" | grep " $old_dirname$")
    if [[ -n "$new_line" ]]; then
      local new_timestamp=$(echo "$new_line" | cut -d' ' -f2)
      if [[ "$old_timestamp" != "$new_timestamp" ]]; then
        log "DEBUG" "Found timestamp change in directory: $old_dirname"
        #  this entry will already be in here as a changed 
        #  dir would appear in both added and deleted dirs
        #  we will enter an assertion at this point that breaks 
        #  with an error to stout if our assumption fails us
        echo -e "\033[31mINTERESTING ERROR: timestamp change in directory $old_dirname!\033[0m"
        echo -e "\033[31mdirectory was not marked as a new or old dir!\033[0m"
        echo -e "\033[31mThis should never happen. Please check.\033[0m"
        echo -e "\033[31mOld timestamp: $old_timestamp, New timestamp: $new_timestamp\033[0m"
      fi
    fi
  done <<< "$old_dirs"

  # Debugging: Print contents of unique_dirs and unique_files
  log "DEBUG" "Contents of unique_dirs: ${!unique_dirs[@]}"
  log "DEBUG" "Contents of unique_files: ${!unique_files[@]}"

  # Add collected directories to the reference array
  for dir in "${!unique_dirs[@]}"; do
    log "DEBUG" "Adding directory to handle: $dir"
    dirs_to_handle_ref+=("$dir")
  done

  # Add collected files to the reference array
  for file in "${!unique_files[@]}"; do
    log "DEBUG" "Adding file to handle: $file"
    files_to_handle_ref+=("$file")
  done

  log "DEBUG" "Directories to handle after comparison: ${dirs_to_handle_ref[*]}"
  log "DEBUG" "Files to handle after comparison: ${files_to_handle_ref[*]}"
}

