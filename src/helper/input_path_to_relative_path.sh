#!/bin/bash

# Example usage:
# INPUT_DIR="/workspace/input"
# absolute_path="/workspace/input/abc/my/path/"
# relative_path=$(input_path_to_relative_path "$absolute_path")
# echo "$relative_path"

input_path_to_relative_path() {
  local absolute_path=$1
  local input_dir=${INPUT_DIR%/}  # Remove trailing slash from INPUT_DIR if any

  # Ensure absolute path starts with input_dir
  if [[ $absolute_path == $input_dir* ]]; then
    # Remove input_dir prefix and prepend ./ to the relative path
    local relative_path="./${absolute_path#$input_dir/}"
    echo "$relative_path"
  else
    echo "Error: The provided path does not start with the INPUT_DIR" >&2
    return 1
  fi
}

