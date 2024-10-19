#! /bin/bash

# Enable strict mode
set -euxo pipefail
IFS=$'\n\t'

sanitize_path() {
    local path=$1
    # Remove trailing /. or /./
    path="${path%.}"
    path="${path%./}"
    echo "$path"
}



