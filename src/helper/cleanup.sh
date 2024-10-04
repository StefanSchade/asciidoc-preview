#!/bin/bash

# Enable strict mode
set -euxo pipefail
IFS=$'\n\t'

cleanup() {
    echo "Cleaning up..."
    # Terminate the watch process
    if [ ! -z "$WATCH_PID" ]; then
        kill $WATCH_PID
        wait $WATCH_PID 2>/dev/null
    fi

    # Terminate the livereload process
    if [ ! -z "$LIVERELOAD_PID" ]; then
        kill $LIVERELOAD_PID
        wait $LIVERELOAD_PID 2>/dev/null
    fi

    exit 0
}
