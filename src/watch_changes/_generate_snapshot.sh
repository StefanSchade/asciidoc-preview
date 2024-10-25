generate_snapshot() {
  local dir=$1
  local -n snapshot=$2
  snapshot=()

  while IFS= read -r -d '' entry; do
    if [ -d "$entry" ]; then
      snapshot+=("D|$(stat --format='%Y' "$entry")|$entry")
    elif [ -f "$entry" ]; then
      snapshot+=("F|$(stat --format='%Y' "$entry")|$entry")
    else
      echo "Warning: '$entry' does not exist or is neither a file nor a directory, skipping..." >&2
    fi
  done < <(find "$dir" -type f \( -name '*.adoc' -o -name '*.asciidoc' \) \
                       -exec dirname {} \; | sort -u | \
                       xargs -I {} find {} \( -type d -o -type f \
                       \( -name '*.adoc' -o -name '*.asciidoc' \) \) -print0)
}

