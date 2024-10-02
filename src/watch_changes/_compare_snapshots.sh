#!/bin/bash

# Enable strict mode
set -euxo pipefail
IFS=$'\n\t'

compare_snapshots() {
  local -n old_snap=$1
  local -n new_snap=$2
  local -n dirs_to_handle_ref=$3
  local -A unique_dirs=()

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
    unique_dirs["$(dirname "$(echo "$line" | cut -d' ' -f3-)")"]=1
  done

  # Check for added files
  comm -13 <(echo "$old_files") <(echo "$new_files") | while read -r line; do
    log "DEBUG" "Found added file: $line"
    unique_dirs["$(dirname "$(echo "$line" | cut -d' ' -f3-)")"]=1
  done

  # Check for timestamp changes in existing directories
  while read -r old_line; do
    local old_timestamp=$(echo "$old_line" | cut -d' ' -f2)
    local old_dirname=$(echo "$old_line" | cut -d' ' -f3-)
    local new_line=$(echo "$new_dirs" | grep " $old_dirname$")
    if [[ -n "$new_line" ]]; then
      local new_timestamp=$(echo "$new_line" | cut -d' ' -f2)
      if [[ "$old_timestamp" != "$new_timestamp" ]]; then
        log "DEBUG" "Found timestamp change in directory: $old_dirname"
        unique_dirs["$old_dirname"]=1
      fi
    fi
  done <<< "$old_dirs"

  # Debugging: Print contents of unique_dirs
  log "DEBUG" "Contents of unique_dirs KEY ${!unique_dirs[@]} VALUE ${unique_dirs[@]}"

  # Add collected directories to the reference array
  for dir in "${!unique_dirs[@]}"; do
    log "DEBUG" "Adding directory to handle: $dir"
    dirs_to_handle_ref+=("$dir")
  done

  log "DEBUG" "Directories to handle after comparison: ${dirs_to_handle_ref[*]}"
}
