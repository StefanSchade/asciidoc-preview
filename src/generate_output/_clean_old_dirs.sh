#!/bin/bash

# Enable strict mode
set -euxo pipefail
IFS=$'\n\t'

clean_old_dirs() {
  log "INFO" "clean_old_dirs from $1"
  find "$1" -mindepth 1           \
            -type d               \
            -not -path "*/\.*"    \
            -print0               | tr '\0' '\n' | while IFS= read -d $'\n' outdir; do
      if [ -n "$outdir" ]; then  # if $dir is empty we do nothing
         relative_output_path=$(output_path_to_relative_path "$outdir")
         indir="${INPUT_DIR}/$relative_output_path"
            log "DEBUG" "checking if directory $indir should be removed"
         if check_dir "$indir"; then
            log "DEBUG" "directory $indir exists - skip removal of $outdir"
         else
            log "DEBUG" "directory $indir does not exist anymore - removing $outdir"
            rm -rf "$outdir"
         fi
      fi
    done
}
 


