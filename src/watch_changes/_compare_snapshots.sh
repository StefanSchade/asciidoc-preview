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

  declare -A old_snapshot_map
  declare -A new_snapshot_map

  # Read old snapshot into associative array
  while IFS='|' read -r prefix old_timestamp entry; do
    old_snapshot_map["$entry"]="$old_timestamp"
  done <<< "$old_snapshot_list"

  # Read new snapshot into associative array
  while IFS='|' read -r prefix new_timestamp entry; do
    new_snapshot_map["$entry"]="$new_timestamp"
  done <<< "$new_snapshot_list"

  # Check for removed entries
  for entry in "${!old_snapshot_map[@]}"; do
    if [[ ! -v new_snapshot_map["$entry"] ]]; then
      log "DEBUG" "Found removed $type: $entry"
      deleted_ref["$entry"]=1
    fi
  done

  # Check for added entries
  for entry in "${!new_snapshot_map[@]}"; do
    if [[ ! -v old_snapshot_map["$entry"] ]]; then
      log "DEBUG" "Found added $type: $entry"
      new_ref["$entry"]=1
    fi
  done

  # Detect timestamp changes
  for entry in "${!old_snapshot_map[@]}"; do
    if [[ -v new_snapshot_map["$entry"] ]]; then
      old_timestamp="${old_snapshot_map["$entry"]}"
      new_timestamp="${new_snapshot_map["$entry"]}"
      if [[ "$old_timestamp" != "$new_timestamp" ]]; then
        log "DEBUG" "Found timestamp change in $type: $entry old timestamp=$old_timestamp new timestamp=$new_timestamp"
        changed_ref["$entry"]=1
        # Remove from new and deleted if marked as both
        unset new_ref["$entry"]
        unset deleted_ref["$entry"]
      fi
    fi
  done
}

