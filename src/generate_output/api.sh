#!/bin/bash

# description:
# this file contains the function definitions that are supposed to be accessed
# by the main function within this folder.

source "$SCRIPT_DIR/generate_output/check_dir.sh"

refresh_output() {
   check_dir "$INPUT_DIR"
}

