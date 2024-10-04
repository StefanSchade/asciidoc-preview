#!/bin/bash

# Enable strict mode
set -euxo pipefail
IFS=$'\n\t'

# Function to check if the input directory is correctly mounted
check_dir() {
    local input_dir=$1
    if [ -d "$input_dir" ]; then
        log "INFO" "$input_dir exists."

        return 0  # Success
    else
        log "WARN" "$input_dir does not exist."  # Log as a warning instead of error
        return 1  # Return non-zero to indicate the directory is missing, but don't exit
    fi
}

# Example usage: check and decide what to do based on the result
# if check_dir "/some/directory"; then
#     echo "Directory exists, proceeding with operations."
# else
#    echo "Directory does not exist, handling this case without exiting."
#    # Handle the missing directory case here (e.g., create the directory or skip certain steps)
#fi

