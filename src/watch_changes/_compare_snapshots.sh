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

  local -A new_dirs=()
  local -A deleted_dirs=()
  local -A changed_dirs=()
  local -A new_files=()
  local -A deleted_files=()
  local -A changed_files=()

  local old_dirs=$(printf "%s\n" "${old_snap[@]}" | grep '^D' | sort)
  local new_dirs=$(printf "%s\n" "${new_snap[@]}" | grep '^D' | sort)
  local old_files=$(printf "%s\n" "${old_snap[@]}" | grep '^F' | sort)
  local new_files=$(printf "%s\n" "${new_snap[@]}" | grep '^F' | sort)

  # Handle directories
  handle_changes "directory" "$old_dirs" "$new_dirs" new_dirs deleted_dirs changed_dirs
  # Handle files
  handle_changes "file" "$old_files" "$new_files" new_files deleted_files changed_files

  # Transfer to reference variables for final output
  new_dirs_ref=("${!new_dirs[@]}")
  deleted_dirs_ref=("${!deleted_dirs[@]}")
  changed_dirs_ref=("${!changed_dirs[@]}")
  new_files_ref=("${!new_files[@]}")
  deleted_files_ref=("${!deleted_files[@]}")
  changed_files_ref=("${!changed_files[@]}")
}

# Generalized change handler
handle_changes() {
  local type=$1
  local old_list=$2
  local new_list=$3
  local -n new_ref=$4
  local -n deleted_ref=$5
  local -n changed_ref=$6

  # Check for removed entries
  comm -23 <(echo "$old_list") <(echo "$new_list") | while read -r line; do
    log "DEBUG" "Found removed $type: $line"
    deleted_ref["$(echo "$line" | cut -d' ' -f3-)"]=1
  done

  # Check for added entries
  comm -13 <(echo "$old_list") <(echo "$new_list") | while read -r line; do
    log "DEBUG" "Found added $type: $line"
    new_ref["$(echo "$line" | cut -d' ' -f3-)"]=1
 done

  # Detect changes based on timestamp differences
  while read -r old_line; do
    local old_timestamp=$(echo "$old_line" | cut -d' ' -f2)
    local entry=$(echo "$old_line" | cut -d' ' -f3-)
    local new_line=$(echo "$new_list" | grep " $entry$")
    if [[ -n "$new_line" ]]; then
      local new_timestamp=$(echo "$new_line" | cut -d' ' -f2)
      if [[ "$old_timestamp" != "$new_timestamp" ]]; then
        log "DEBUG" "Found timestamp change in $type: $entry"
        changed_ref["$entry"]=1
        # Remove from both new and deleted if it was marked as both (meaning it changed)
        unset new_ref["$entry"]
        unset deleted_ref["$entry"]
      fi
    fi
  done <<< "$old_list"
}

