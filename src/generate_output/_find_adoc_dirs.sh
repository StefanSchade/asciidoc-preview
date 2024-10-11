#!/bin/bash
#
# Example usage
# declare -a adoc_dirs=()
# find_adoc_dirs "/path/to/start" adoc_dirs

# Enable strict mode
set -euxo pipefail
IFS=$'\n\t'

find_subdirectories() {
    local start_path="$1"
    local subdirs

    # Use find to collect subdirectories
    subdirs=$(find "$start_path" -type d -print)

    # Filter out unnecessary entries
    filtered_subdirs=()
    while IFS= read -r subdir; do
        if [[ -n "$subdir" && "$subdir" != */. && "$subdir" != */.. ]]; then
            # Remove trailing "/." from paths
            subdir=$(echo "$subdir" | sed 's:/$::g')
            filtered_subdirs+=("$subdir")
        fi
    done <<< "$subdirs"

    # Deduplicate the list
    unique_subdirs=($(printf "%s\n" "${filtered_subdirs[@]}" | sort -u))

    # Return the unique, filtered list
    echo "${unique_subdirs[@]}"
}

# Traverse the directories to look for .adoc files
find_adoc_dirs() {
    local start_path="$1"
    local -n adoc_dirs_ref="$2"  # nameref to update adoc_dirs_ref array

    # Step 1: Get all subdirectories, filter and normalize them
    subdirs=$(find_subdirectories "$start_path")

    # Step 2: Check each subdirectory for .adoc files
    for subdir in ${subdirs[@]}; do
        echo "Checking subdir: $subdir"
        if find "$subdir" -maxdepth 1 -name "*.adoc" | read -r; then
            adoc_dirs_ref+=("$subdir")
            echo "Found .adoc in: $subdir"
        fi
    done
}

