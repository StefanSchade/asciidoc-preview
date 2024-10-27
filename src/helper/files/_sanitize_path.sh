#!/bin/bash

# Enable strict mode
set -euxo pipefail
IFS=$'\n\t'

sanitize_path() {
    local path="$1"
    log "DEBUG" "sanitize_path(): start sanitization input='$path'"

    if [ "$path" == "." ]; then
        log "DEBUG" "sanitize_path(): path is exactly '.', leaving it unchanged."
        echo "."
        return
    fi

    if [[ "$path" == "./"* ]]; then
        path="${path#./}"
        log "DEBUG" "sanitize_path(): removed leading './', new path='$path'"
    fi

    if [[ "$path" == *"/./"* ]]; then
        path="${path//\/.\//\/}"
        log "DEBUG" "sanitize_path(): removed '/./' patterns in the middle, new path='$path'"
    fi

    while [[ "$path" == */. || "$path" == */./ ]]; do
        if [[ "$path" == */./ ]]; then
            path="${path%./}"
            log "DEBUG" "sanitize_path(): removed trailing '/./', new path='$path'"
        fi
        if [[ "$path" == */. ]]; then
            path="${path%.}"
            log "DEBUG" "sanitize_path(): removed trailing '/.', new path='$path'"
        fi
    done

    if [ -z "$path" ]; then
        path="."
        log "DEBUG" "sanitize_path(): path is empty after sanitization, setting it to '.'"
    fi

    if [[ "$path" != */ ]]; then
        path="$path/"
        log "DEBUG" "sanitize_path(): appended trailing '/', new path='$path'"
    fi

    log "DEBUG" "sanitize_path(): final sanitized path='$path'"
    echo "$path"
}

