#!/bin/bash

# description:
# this tool helps to perform logging from bash scripts. It has the following
# features
# - provide log levels
# - limit the logfile size by roling
#
# usage:
# log "INFO" "This is an info message."
# log "ERROR" "This is an error message."
# log "DEBUG" "This is a debug message."
# log "INFO" "The log function" "can take" "multiple messages" "at once"


: "${LOG_FILE:=/var/log/default_log_file.log}"    # default path if not set externally
: "${LOG_LEVEL:=INFO}"                            # default log level if not set ext.

MAX_SIZE=$((6 * 1024 * 1024))           # 6 MB
THRESHOLD_SIZE=$((5 * 1024 * 1024))     # 5 MB

# log function
log() {
    local level=$1
    shift
    local message=$@
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    declare -A levels=( ["ERROR"]=0 ["WARN"]=1 ["INFO"]=2 ["DEBUG"]=3 )
    if (( ${levels[$level]} <= ${levels[$LOG_LEVEL]} )); then
        echo "$timestamp [$level] $message" >> "$LOG_FILE"
    fi

    # Check log file size and rotate if necessary
    local file_size=$(stat -c%s "$LOG_FILE")
    if (( file_size > MAX_SIZE )); then
        echo "Log file size exceeded $MAX_SIZE bytes, rotating log file." >&2
        local temp_file=$(mktemp)

        tail -c $THRESHOLD_SIZE "$LOG_FILE" > "$temp_file" && cat "$temp_file" > "$LOG_FILE"
        truncate -s $THRESHOLD_SIZE "$LOG_FILE"
        rm "$temp_file"
        echo "Log file trimmed to $THRESHOLD_SIZE bytes." >&2
    fi
 }

# Function to log the output of a command line by line
# Example usage: Log the output of ls command
# log "INFO" "Logging the output of ls command"
# ls_output=$(ls -la /workspace/output)
# log_command_output "INFO" "$ls_output"
log_command_output() {
    local level=$1
    shift
    local command_output="$@"
    while IFS= read -r line; do
        log "$level" "$line"
    done <<< "$command_output"
}

