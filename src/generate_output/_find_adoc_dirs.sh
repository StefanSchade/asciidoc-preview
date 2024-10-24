#!/bin/bash

# Enable strict mode
set -euo pipefail
IFS=$'\n\t'

# Function to find directories containing .adoc files
find_adoc_dirs() {
    local search_dir="$1"
    local -n adoc_dir_array_ref="$2"

    adoc_dir_array_ref=()
    while IFS= read -r -d '' dir; do
        # Remove the INPUT_DIR prefix to get the relative path
        relative_dir="${dir#$INPUT_DIR/}"
        adoc_dir_array_ref+=("$relative_dir")
    done < <(
        find "$search_dir" -type f \( -name '*.adoc' -o -name '*.asciidoc' \) -printf '%h\0' | sort -zu
    )
}

