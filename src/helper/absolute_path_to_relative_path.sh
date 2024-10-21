#!/bin/bash

# Enable strict mode
set -euo pipefail
IFS=$'\n\t'

absolute_path_to_relative_path() {
  local absolute_path=$1
  local base_path=${2%/}  # Remove trailing slash from base path if any

  # Ensure absolute path starts with base_path
  if [[ $absolute_path == $base_path* ]]; then
    # Remove base_path and any leading slash from the result
    local relative_path="${absolute_path#$base_path}"
    relative_path="${relative_path#/}"
    echo "$relative_path"
  else
    echo "Error: The provided path does not start with the base path" >&2
    exit 1
  fi
}

