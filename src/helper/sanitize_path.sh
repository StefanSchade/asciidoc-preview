#! /bin/bash

sanitize_path() {
    local path=$1
    # Remove trailing /. or /./
    path="${path%.}"
    path="${path%./}"
    echo "$path"
}



