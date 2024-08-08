#!/bin/bash

# Function to check if the input directory is correctly mounted
check_dir() {
    local input_dir=$1
    if [ -d "$input_dir" ]; then
        log "INFO" "$input_dir exists."
    else
        log "ERROR" "$input_dir does not exist."
        exit 1
    fi
}

