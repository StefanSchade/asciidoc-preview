#!/bin/bash
#
# Recursively search a directory structure for all directories containing an .adoc
# To avoid pitfals by endless recursions (which may occur due to soft links in the 
# dir structure) and directories with very many subdirectories (which can occur in
# generated code, system folders and the like but likely not in folders containing
# .adoc) we stop the search at a certain debth or in directories with to many sub-
# directories.

# Enable strict mode
set -euxo pipefail
IFS=$'\n\t'

MAX_SUBDIRS=200
MAX_DEPTH=20

# Function takes a relative start path as an iput that is prepended with the global
# INPUT_DIR vaild throughout this bash program. it takes a second argument which is
# used as a return value. The optional third argument is used when recursively calling
# the function again.
#
find_adoc_dirs() {
    local relative_start_path="$1"
    declare -n adoc_dirs_ref="$2"  # nameref
    local current_depth="${3:-1}"  # not set when called from outside - default to 1

    local absolute_input_start_path="${INPUT_DIR}/${relative_start_path}"
    echo "Searching for adocs in $absolute_input_start_path at depth $current_depth"

    # Find subdirectories
    local subdirs
    local subdir_count
    subdirs=$(find "$absolute_input_start_path" -mindepth 1 -maxdepth 1 -type d)
    subdir_count=$(echo "$subdirs" | wc -l)

    # Check if max depth or max subdirs are exceeded
    if (( subdir_count > MAX_SUBDIRS )); then
        echo "Maximum number of subdirectories $MAX_SUBDIRS exceeded. Stopping recursion."
        return
    elif (( current_depth > MAX_DEPTH )); then
        echo "Maximum depth $MAX_DEPTH exceeded in $relative_start_path. Stopping recursion."
        return
    fi

    # Process each subdirectory
    while IFS= read -r subdir; do
      echo "Checking subdir: $subdir"
      local relative_subdir
      # Skip directories that are not really subdirs
      if [[ "$subdir" != "$absolute_input_start_path" && \
            "$subdir" != "$absolute_input_start_path/.." && \
            "$subdir" != "$absolute_input_start_path/." ]]; then
        # Recursively search in the subdirectory regardless of .adoc presence
        relative_subdir="${subdir#$INPUT_DIR/}" # Remove base path
        
        # Continue recursion before checking for .adoc files
        find_adoc_dirs "$relative_subdir" adoc_dirs_ref $((current_depth + 1))

        # Only add to the result if this directory contains .adoc files
        if find "$subdir" -maxdepth 1 -name "*.adoc" | read -r; then
          echo "Found .adoc in: $relative_subdir"
          adoc_dirs_ref+=("$relative_subdir")
        fi
      fi
    done <<< "$subdirs"
}

# Call the function for testing (this should be called in your main script)
adoc_dir_array=()
find_adoc_dirs "." adoc_dir_array

