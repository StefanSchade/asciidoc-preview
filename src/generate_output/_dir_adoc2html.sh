#!/bin/bash

# Enable strict mode
set -euo pipefail
IFS=$'\n\t'

# Include the find_adoc_dirs script
source "${BASH_SOURCE%/*}/_find_adoc_dirs.sh"

# Function to convert .adoc files to .html
dir_adoc2html() {
    local relative_start_path=${1:-"."}

    log "INFO" "dir_adoc2html(): looking for adocs in $INPUT_DIR$relative_start_path"

    # Find directories containing .adoc files
    adoc_dir_array=()
    find_adoc_dirs "$INPUT_DIR$relative_start_path" adoc_dir_array

    log "INFO" "dir_adoc2html(): Number of subdirectories found: ${#adoc_dir_array[@]}"
    log "INFO" "dir_adoc2html(): Directories that have to be processed: ${adoc_dir_array[*]}"

    for subdir in "${adoc_dir_array[@]}"; do
        subdir=$(sanitize_path "$subdir")
        subdir=$(input_path_to_relative_path "$subdir")

        log "INFO" "Processing dir $subdir"

        # Create the corresponding output directory
        mkdir -p "$OUTPUT_DIR$subdir"

        # Find .adoc files in the current subdirectory
        find "$INPUT_DIR$subdir" -maxdepth 1 -type f \( -name '*.adoc' -o -name '*.asciidoc' \) | while read -r adoc_file; do
            # Extract the filename without extension
            filename=$(basename "${adoc_file%.*}")
            output_file="$OUTPUT_DIR$subdir$filename.html"

            log "INFO" "---- $adoc_file"
            # Convert .adoc to .html
            asciidoctor "$adoc_file" -o "$output_file"
            log "INFO" "Converted $adoc_file to $output_file"
        done
    done
}

