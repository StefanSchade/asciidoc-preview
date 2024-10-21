#! /bin/bash

# Enable strict mode
set -euxo pipefail
IFS=$'\n\t'

sanitize_path() {
    local path=$1

    # If path is exactly ".", leave it unchanged
    if [ "$path" == "." ]; then
        echo "."
        return
    fi

    # Remove trailing /. or /./
    path="${path%.}"
    path="${path%./}"

# Remove leading ./
    path="${path#./}"
    echo "$path"
}



