#! /bin/bash

# Enable strict mode
set -euxo pipefail
IFS=$'\n\t'

sanitize_path() {
    local path="$1"
    log "DEBUG" "sanitize_path(): input=$path"
    # If path is exactly ".", leave it unchanged
    if [ "$path" == "." ]; then
        echo "."
        log "DEBUG" "sanitize_path(): position 1 - output=."
        return
    fi

    # Remove leading './' only
    if [[ "$path" == "./"* ]]; then
        path="${path#./}"
        log "DEBUG" "sanitize_path(): position 2 - output=$path"
    fi

    # Remove trailing '/.' or '/./' repeatedly
    while [[ "$path" == */. || "$path" == */./ ]]; do
        if [[ "$path" == */./ ]]; then
            path="${path%/./}"
            log "DEBUG" "sanitize_path(): position 3 - output=$path"
        fi
        if [[ "$path" == */. ]]; then
            path="${path%/.}"
            log "DEBUG" "sanitize_path(): position 4 - output=$path"
        fi
    done

    # If path is empty after sanitization, set it to '.'
    if [ -z "$path" ]; then
        echo "."
        log "DEBUG" "sanitize_path(): position 5 - output=$path"
    else
        echo "$path"
        log "DEBUG" "sanitize_path(): position 6 - output=$path"
    fi
}

