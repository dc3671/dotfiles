#!/bin/bash

# Configuration
SOURCE_DIR="/usr/local/lib/python3.12/dist-packages"
TARGET_DIR="$CONDA_PREFIX/lib/python3.12/site-packages"
PACKAGES=("torch" "functorch" "triton" "tensorrt" "nvidia" "pytorch-triton")

COPY_PACKAGES=("triton*" "torchao" "nvidia" "nvidia-modelopt-core*" "nvidia-cuda-nvrtc*" "*dist-info")
should_copy_package() {
    local basename="$1"

    for copy_pkg in "${COPY_PACKAGES[@]}"; do
        if [[ "$basename" == $copy_pkg ]]; then
            return 0
        fi
    done

    return -1
}

# Function to update a package
update_package() {
    local package="$1"
    local source_pattern="$SOURCE_DIR/${package}*"
    local target_pattern="$TARGET_DIR/${package}*"

    # Check if source exists before proceeding
    if ! ls $source_pattern >/dev/null 2>&1; then
        echo "Warning: No ${package}* packages found in source directory"
        return 1
    fi

    echo "Updating ${package}* packages..."

    # Remove existing packages
    rm -rf $target_pattern 2>/dev/null

    # Process each matching source item
    for source_item in $source_pattern; do
        if [ -d "$source_item" ]; then
            local basename=$(basename "$source_item")
            local target_item="$TARGET_DIR/$basename"

            if should_copy_package "$basename"; then
                echo "Copying $basename (directory)"
                cp -rf "$source_item" "$target_item"
            else
                echo "Linking $basename (directory)"
                ln -sf "$source_item" "$target_item"
            fi
        else
            # Handle files normally (copy)
            cp -rf "$source_item" "$TARGET_DIR/"
        fi
    done

    # List updated packages
    ls -lh $target_pattern -d 2>/dev/null || echo "Warning: Failed to list ${package}* packages"
}

# Update all packages
for package in "${PACKAGES[@]}"; do
    update_package "$package"
    echo
done

echo "Package update completed."
