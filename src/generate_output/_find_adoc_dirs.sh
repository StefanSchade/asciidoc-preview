#!/bin/bash
#
# Recursively search a directory structure for all directories containing an .adoc
# This script stops the search at a certain depth or in directories with too many sub-
# directories to avoid endless recursion or processing very large directories.

# Enable strict mode
set -euxo pipefail
IFS=$'\n\t'

MAX_SUBDIRS=200
MAX_DEPTH=20

# Function takes a relative start path as input, prepends it with INPUT_DIR (set globally),
# and takes a second argument used for the result. The optional third argument is the 
# recursion depth, which defaults to 1 on the initial call.
find_adoc_dirs() {
    local relative_start_path="$1"
    local adoc_dirs_ref_name=$2
    local current_depth="${3:-1}"

    local absolute_input_start_path="${INPUT_DIR}/${relative_start_path}"
    echo "Searching for adocs in $absolute_input_start_path at depth $current_depth"

    # Exit early if current depth exceeds MAX_DEPTH
    if (( current_depth > MAX_DEPTH )); then
        echo "Maximum depth $MAX_DEPTH exceeded in $relative_start_path. Stopping recursion."
        return
    fi

    # Find subdirectories, skipping .git and other irrelevant directories
    local subdirs
    subdirs=$(find "$absolute_input_start_path" -mindepth 1 -maxdepth 1 -type d \
                                                ! -path '*/.git/*'              \
                                                ! -name '.git'                  \
                                                ! -name 'docker'                \
                                                ! -name 'node_modules')

    local subdir_count
    subdir_count=$(echo "$subdirs" | wc -l)

    # Check if max number of subdirectories is exceeded
    if (( subdir_count > MAX_SUBDIRS )); then

        echo "Maximum number of subdirectories $MAX_SUBDIRS exceeded. Stopping recursion."
        return
    fi

    # Process each subdirectory
    while IFS= read -r subdir; do
        echo "Checking subdir: $subdir"
        local relative_subdir=""

        # Skip directories that are not valid subdirectories
        if [[ -z "$subdir" || \
              "$subdir" == "$absolute_input_start_path" || \
              "$subdir" == "$absolute_input_start_path/.." || \
              "$subdir" == "$absolute_input_start_path/." ]]; then
            continue
        fi

        # Check for .adoc files in this directory
        if find "$subdir" -maxdepth 1 -name "*.adoc" | read -r; then
            relative_subdir="${subdir#$INPUT_DIR/}"  # Remove base path
            echo "Found .adoc in: $relative_subdir"
            eval "$adoc_dirs_ref_name+=(\"$relative_subdir\")"
        fi

        # Recursively search the subdirectory
        find_adoc_dirs "$relative_subdir" "$adoc_dirs_ref_name" $((current_depth + 1))
    done <<< "$subdirs"
}

