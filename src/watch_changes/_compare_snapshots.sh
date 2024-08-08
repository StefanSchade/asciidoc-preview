#!/bin/bash

compare_snapshots() {
  local -n old_snap=$1
  local -n new_snap=$2
  local -n dirs_to_handle_ref=$3
  local -A dirs_to_handle=()

  local old_dirs=$(printf "%s\n" "${old_snap[@]}" | grep '^D' | sort)
  local new_dirs=$(printf "%s\n" "${new_snap[@]}" | grep '^D' | sort)
  local old_files=$(printf "%s\n" "${old_snap[@]}" | grep '^F' | sort)
  local new_files=$(printf "%s\n" "${new_snap[@]}" | grep '^F' | sort)

  comm -23 <(echo "$old_dirs") <(echo "$new_dirs") | while read -r line; do
    dirs_to_handle["$(dirname "$(echo "$line" | cut -d' ' -f3-)")"]=1
  done

  comm -13 <(echo "$old_dirs") <(echo "$new_dirs") | while read -r line; do
    dirs_to_handle["$(dirname "$(echo "$line" | cut -d' ' -f3-)")"]=1
  done

  comm -23 <(echo "$old_files") <(echo "$new_files") | while read -r line; do
    dirs_to_handle["$(dirname "$(echo "$line" | cut -d' ' -f3-)")"]=1
  done

  comm -13 <(echo "$old_files") <(echo "$new_files") | while read -r line; do
    dirs_to_handle["$(dirname "$(echo "$line" | cut -d' ' -f3-)")"]=1
  done

  for dir in "${!dirs_to_handle[@]}"; do
    dirs_to_handle_ref+=("$dir")
  done

  log "DEBUG" "Directories to handle after comparison: ${dirs_to_handle_ref[*]}"
}

