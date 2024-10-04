#!/bin/bash

# Enable strict mode
set -euxo pipefail
IFS=$'\n\t'

# Function to check if a file or directory exists
check_existence() {
    local path=$1
    local type=$2  # 'dir' or 'file'

    if [[ "$type" == "dir" && -d "$path" ]]; then
        log "INFO" "Directory $path exists."
        return 0  # Success
    elif [[ "$type" == "file" && -f "$path" ]]; then
        log "INFO" "File $path exists."
        return 0  # Success
    else
        log "WARN" "$path does not exist."

        return 1  # Return non-zero to indicate the path is missing
    fi
}

# Check directory by calling check_existence
check_dir() {
   check_existence "$1" "dir"
   return $?  # Return the result of check_existence
}

# Check file by calling check_existence
check_file() {
   check_existence "$1" "file"
   return $?  # Return the result of check_existence
}

