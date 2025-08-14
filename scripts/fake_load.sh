#!/bin/bash

# Script to pre-load .safetensors files into disk cache
# Usage: ./fake_load.sh [directory]

# Set default directory or use provided argument
DIR="${1:-.}"

# Check if directory exists
if [ ! -d "$DIR" ]; then
    echo "Error: Directory '$DIR' does not exist"
    exit 1
fi

echo "Pre-loading .safetensors files from: $DIR"

# Find and cat all .safetensors files
find "$DIR" -name "*.safetensors" -type f | while read -r file; do
    echo "Loading: $file"
    cat "$file" > /dev/null
done

echo "Done pre-loading files into cache"
