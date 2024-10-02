#!/bin/bash

# Enable strict mode
set -euo pipefail
IFS=$'\n\t'

absolute_path_to_relative_path() {
  local absolute_path=$1
  local base_path=${2%/}  # Remove trailing slash from base path if any

  # Ensure absolute path starts with base_path
  if [[ $absolute_path == $base_path* ]]; then
    echo "${absolute_path#$base_path/}"
  else
    echo "Error: The provided path does not start with the base path" >&2
    return 1
  fi
}

# Delegate function for input path
input_path_to_relative_path() {
  absolute_path_to_relative_path "$1" "$INPUT_DIR"
}

# Delegate function for output path
output_path_to_relative_path() {
  absolute_path_to_relative_path "$1" "$OUTPUT_DIR"
}

