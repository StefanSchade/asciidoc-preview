#!/bin/bash

generate_snapshot() {
  local dir=$1
  local -n snapshot=$2
  snapshot=()

  while IFS= read -r -d '' entry; do
    if [ -d "$entry" ]; then
      snapshot+=("D $(stat --format='%Y' "$entry") $entry")
    else
      snapshot+=("F $(stat --format='%Y' "$entry") $entry")
    fi
  done < <(find "$dir" \( -type d -o -type f \( -name '*.adoc' -o -name '*.asciidoc' \) \) -print0)

  log "DEBUG" "Snapshot for $dir: ${snapshot[*]}"

}

