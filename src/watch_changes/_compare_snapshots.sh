#!/bin/bash

# Enable strict mode
set -euxo pipefail
IFS=$'\n\t'

# Compare snapshots and categorize changes
compare_snapshots() {
  local -n old_snap=$1
  local -n new_snap=$2
  local -n new_dirs_ref=$3
  local -n deleted_dirs_ref=$4
  local -n changed_dirs_ref=$5
  local -n new_files_ref=$6
  local -n deleted_files_ref=$7
  local -n changed_files_ref=$8

  local -A new_dirs_unique=()
  local -A deleted_dirs_unique=()
  local -A changed_dirs_unique=()
  local -A new_files_unique=()
  local -A deleted_files_unique=()
  local -A changed_files_unique=()

  # Process directories
  local old_dirs_snapshot
  old_dirs_snapshot=$(printf "%s\n" "${old_snap[@]}" | grep '^D' || true | sort)
  local new_dirs_snapshot
  new_dirs_snapshot=$(printf "%s\n" "${new_snap[@]}" | grep '^D' || true | sort)
  
  # Process files
  local old_files_snapshot
  old_files_snapshot=$(printf "%s\n" "${old_snap[@]}" | grep '^F' || true | sort)
  local new_files_snapshot
  new_files_snapshot=$(printf "%s\n" "${new_snap[@]}" | grep '^F' || true | sort)

  # Handle directories
  handle_changes "directory" "$old_dirs_snapshot" "$new_dirs_snapshot" new_dirs_unique deleted_dirs_unique changed_dirs_unique

  # Handle files
  handle_changes "file" "$old_files_snapshot" "$new_files_snapshot" new_files_unique deleted_files_unique changed_files_unique

  # Transfer to reference variables for final output
  new_dirs_ref=("${!new_dirs_unique[@]}")
  deleted_dirs_ref=("${!deleted_dirs_unique[@]}")
  changed_dirs_ref=("${!changed_dirs_unique[@]}")
  new_files_ref=("${!new_files_unique[@]}")
  deleted_files_ref=("${!deleted_files_unique[@]}")
  changed_files_ref=("${!changed_files_unique[@]}")
}

# Generalized change handler
handle_changes() {
  local type=$1
  local old_snapshot_list=$2
  local new_snapshot_list=$3
  local -n new_ref=$4
  local -n deleted_ref=$5
  local -n changed_ref=$6

  # Check for removed entries (in old but not in new)
  while read -r line; do
    if [ -n "$line" ]; then
      log "DEBUG" "Found removed $type: $line"
      deleted_ref["$(echo "$line" | cut -d' ' -f3-)"]=1
    fi
  done < <(comm -23 <(echo "$old_snapshot_list") <(echo "$new_snapshot_list"))

  # Check for added entries (in new but not in old)
  while read -r line; do
    if [ -n "$line" ]; then
      log "DEBUG" "Found added $type: $line"
      new_ref["$(echo "$line" | cut -d' ' -f3-)"]=1
    fi
  done < <(comm -13 <(echo "$old_snapshot_list") <(echo "$new_snapshot_list"))

  # Detect changes based on timestamp differences
  while read -r old_line; do
    local old_timestamp
    old_timestamp=$(echo "$old_line" | cut -d' ' -f2)
    local entry
    entry=$(echo "$old_line" | cut -d' ' -f3-)
    local new_line
    new_line=$(echo "$new_snapshot_list" | grep "$entry$" || true)
    if [[ -n "$new_line" ]]; then
      local new_timestamp
      new_timestamp=$(echo "$new_line" | cut -d' ' -f2)
      if [[ "$old_timestamp" != "$new_timestamp" ]]; then
        log "DEBUG" "Found timestamp change in $type: $entry old timestamp=$old_timestamp new timestamp=$new_timestamp"
        changed_ref["$entry"]=1
        # Remove from both new and deleted if it was marked as both
        unset new_ref["$entry"]
        unset deleted_ref["$entry"]
      fi
    fi
  done <<< "$old_snapshot_list"
}

