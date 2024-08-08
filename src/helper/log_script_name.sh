#!/bin/bash

source "$SCRIPT_DIR/helper/logger.sh"

log_script_name() {

    local script_name=$(basename "$0")
    local star_line=$(printf '%*s' "${#script_name}" | tr ' ' '*')

    log "INFO" "**""${star_line}""**"
    log "INFO" "* ""${script_name}"" *"
    log "INFO" "**""${star_line}""**"
}

