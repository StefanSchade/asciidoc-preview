#!/bin/bash

# Enable strict mode
set -euxo pipefail
IFS=$'\n\t'

find_adoc_dirs() {
  local start_path="$1"
  local -n adoc_dirs_ref="$2"  # Name reference to update adoc_dirs_ref array

  # Normalize start_path
  start_path="${start_path%/}"

  # Find all .adoc files and extract their directories
  local adoc_files
  mapfile -t adoc_files < <(find "$start_path" -type f -name "*.adoc")

  local dirs_set=()
  declare -A seen_dirs=()

  for file in "${adoc_files[@]}"; do
    dir=$(dirname "$file")
    dir="${dir%/}"  # Remove trailing slash if any
    # Get relative path
    dir=$(absolute_path_to_relative_path "$dir" "$start_path")
    # Ensure the directory is not already added
    if [[ ! -v 'seen_dirs[$dir]' ]]; then
      dirs_set+=("$dir")
      seen_dirs["$dir"]=1
    fi
  done

  adoc_dirs_ref=("${dirs_set[@]}")
}

