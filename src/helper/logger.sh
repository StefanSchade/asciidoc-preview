#!/bin/bash

# Enable strict mode
set -euxo pipefail
IFS=$'\n\t'

# Set default values if the variables are not provided
: "${LOG_FILE:=/var/log/default_log_file.log}"    # Default log file
: "${LOG_LEVEL:=INFO}"                            # Default log level

MAX_SIZE=$((6 * 1024 * 1024))           # 6 MB
THRESHOLD_SIZE=$((5 * 1024 * 1024))     # 5 MB

# Log function
log() {
    local level="${1//[[:space:]]/}"
    shift
    local message="$*"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    # Define log levels
    declare -A levels=( ["ERROR"]=0 ["WARN"]=1 ["INFO"]=2 ["DEBUG"]=3 )

    # Check if the log level allows logging this message
    if (( ${levels[$level]:-3} <= ${levels[$LOG_LEVEL]:-3} )); then
        if ! echo "$timestamp [$level] $message" >> "$LOG_FILE"; then
            echo "Failed to write to log file: $LOG_FILE" >&2
        fi
    fi

    # Check log file size and rotate if necessary
    if [[ -f "$LOG_FILE" ]]; then
        local file_size=$(stat -c%s "$LOG_FILE")
        if (( file_size > MAX_SIZE )); then
            echo "Log file size exceeded $MAX_SIZE bytes, rotating log file." >&2
            local temp_file=$(mktemp)

            # Rotate the log file, keeping only the last THRESHOLD_SIZE bytes
            tail -c $THRESHOLD_SIZE "$LOG_FILE" > "$temp_file" && mv "$temp_file" "$LOG_FILE"
            echo "Log file trimmed to $THRESHOLD_SIZE bytes." >&2
        fi
    fi
}
