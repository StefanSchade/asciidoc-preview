#! /bin/bash

# Enable strict mode
set -euxo pipefail
IFS=$'\n\t'

join_by() {
    local IFS="$1"
    shift
    echo "$*"
}


