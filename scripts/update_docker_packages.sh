#!/bin/bash

# Configuration
SOURCE_DIR="/usr/local/lib/python3.12/dist-packages"
TARGET_DIR="$CONDA_PREFIX/lib/python3.12/site-packages"
PACKAGES=("torch" "functorch" "triton" "tensorrt" "nvidia" "pytorch_triton" "cuda")

# Copy (don't symlink) packages that requirements.txt pins to a different version
# than the container ships, so pip can uninstall/downgrade them in place. A
# symlink into the container's read-only dist-packages breaks pip's uninstall
# with `OSError: ... No such file or directory: '<pkg>/__init__.py'`.
# e.g. torchao (container 0.17.0 vs pinned <0.16.0),
#      torch_c_dlpack_ext (container 0.1.5 vs pinned ==0.1.3).
COPY_PACKAGES=("triton*" "torchao*" "torch_c_dlpack_ext*" "functorch*" "nvidia*" "mpi4py*" "nvidia-modelopt-core*" "nvidia-cuda-nvrtc*" "nvidia_cutlass_dsl*" "cuda*" "*dist-info")
should_copy_package() {
    local basename="$1"

    for copy_pkg in "${COPY_PACKAGES[@]}"; do
        if [[ "$basename" == $copy_pkg ]]; then
            return 0
        fi
    done

    return -1
}

# Skip these entirely (don't copy or link) — let `pip install -r requirements`
# provide them. Needed when a package's importable module is NOT captured by the
# PACKAGES prefixes but its *-dist-info IS (matched by `nvidia*`/`*dist-info`).
# The stray dist-info makes pip think the requirement is satisfied and skip
# installing it, leaving the module missing at import time.
# e.g. nvidia_ml_py ships top-level `pynvml.py` (not under the `nvidia` prefix),
#      so only its dist-info gets copied -> `ModuleNotFoundError: No module named
#      'pynvml'`. It's a tiny pure-python pinned dep; pip installs it cleanly.
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
