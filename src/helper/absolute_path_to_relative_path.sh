#!/bin/bash

# Enable strict mode
set -euo pipefail
IFS=$'\n\t'

absolute_path_to_relative_path() {
    local absolute_path=$1
    local base_path=$2

    if [[ $absolute_path == $base_path* ]]; then
        local relative_path=${absolute_path#$base_path}
        relative_path=${relative_path#/}

        # If relative_path is empty, set it to "."
        if [[ -z "$relative_path" ]]; then
            relative_path="."
        fi

        echo "$relative_path"
    else
        echo "Error: The provided path does not start with the base path" >&2
        exit 1
    fi
}

output_path_to_relative_path() {
   absolute_path_to_relative_path $1 $OUTPUT_DIR
}

input_path_to_relative_path() {
   absolute_path_to_relative_path $1 $INPUT_DIR
}
