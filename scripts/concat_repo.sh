#!/bin/bash

rm output.txt
find "$1" -type f -not -path '*/.git/*' -exec sh -c 'echo "--- {} ---" >> output.txt; cat {} >> output.txt; echo "" >> output.txt' \;
