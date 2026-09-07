#!/bin/bash

# Configuration
SOURCE_DIR="/usr/local/lib/python3.12/dist-packages"
TARGET_DIR="$CONDA_PREFIX/lib/python3.12/site-packages"
PACKAGES=("torch" "functorch" "triton" "tensorrt" "nvidia" "pytorch_triton" "cuda" "flash_attn")

# Copy (don't symlink) packages pinned to a version the container doesn't ship, so
# pip can uninstall in place -- symlinks into read-only dist-packages fail with
# `OSError: ... '<pkg>/__init__.py'`. e.g. torchao 0.17.0 vs pinned <0.16.0.
#
# flash_attn is two packages sharing one dir: pinned flash-attn-4 (4.0.0b19) ships
# only cute/* and lacks flash_attn_with_kvcache, which lives in container-only
# flash_attn 2.7.4. Copying keeps it through pip's cute b11 -> b19 upgrade.
COPY_PACKAGES=("triton*" "torchao*" "torch_c_dlpack_ext*" "functorch*" "nvidia*" "mpi4py*" "nvidia-modelopt-core*" "nvidia-cuda-nvrtc*" "nvidia_cutlass_dsl*" "cuda*" "flash_attn*" "*dist-info")
should_copy_package() {
    local basename="$1"

    for copy_pkg in "${COPY_PACKAGES[@]}"; do
        if [[ "$basename" == $copy_pkg ]]; then
            return 0
        fi
    done

    return -1
}

# Skip entirely -- let `pip install -r requirements` provide them. Needed when the
# importable module escapes the PACKAGES prefixes but its dist-info doesn't: the
# stray dist-info satisfies pip, so it never installs the module.
# e.g. nvidia_ml_py ships top-level pynvml.py -> `ModuleNotFoundError: 'pynvml'`.
SKIP_PACKAGES=("nvidia_ml_py*" "nvidia-ml-py*")
should_skip_package() {
    local basename="$1"

    for skip_pkg in "${SKIP_PACKAGES[@]}"; do
        if [[ "$basename" == $skip_pkg ]]; then
            return 0
        fi
    done

    return 1
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
        local basename=$(basename "$source_item")

        if should_skip_package "$basename"; then
            echo "Skipping $basename (pip will install it)"
            continue
        fi

        if [ -d "$source_item" ]; then
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
