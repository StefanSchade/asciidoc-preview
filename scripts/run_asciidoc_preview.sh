#!/bin/bash
# Script to build and start the asciidoc-preview container

if [ -z "$1" ]; then
    echo "Usage: run_asciidoc_preview.sh [document_path]"
    exit 1
fi

DOCUMENT_DIR="$1"

if [ ! -e "$DOCUMENT_DIR" ]; then
    echo "The specified path does not exist."
    exit 1
fi

# Check if the path is absolute
if [[ "$DOCUMENT_DIR" != /* ]]; then
    # Convert relative path to absolute path
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    DOCUMENT_DIR="$SCRIPT_DIR/$DOCUMENT_DIR"
fi

# Sanitize the DOCUMENT_DIR to create a valid container name
SANITIZED_PATH=$(echo "$DOCUMENT_DIR" | sed 's/[:\\\/]/_/g')

# Set the image name
IMAGE_NAME="asciidoc-preview"

# Set the container name
CONTAINER_NAME="${IMAGE_NAME}_${SANITIZED_PATH}"

cd ..

docker build -t "$IMAGE_NAME" -f "docker/Dockerfile" .

docker run -it --rm -p 35729:35729 -p 4000:4000 \
    -v "$DOCUMENT_DIR":/workspace/input \
    -w /workspace \
    --name "$IMAGE_NAME" "$IMAGE_NAME"

echo "$IMAGE_NAME"

cd scripts

