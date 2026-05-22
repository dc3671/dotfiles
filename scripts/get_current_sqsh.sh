#!/usr/bin/env bash
# Resolve the sqsh container image corresponding to the current
# LLM_DOCKER_IMAGE recorded in jenkins/current_image_tags.properties.
#
# Jenkins tag:   ...-tritondevel-202604011104-12600
# Matching sqsh: <SQSH_DIR>/tensorrt-llm-202604011104-1260.sqsh
#
# The sqsh filename uses a truncated (first 4-digit) MR suffix, so we
# locate the file by timestamp glob and optionally filter by variant
# (plain / GB200-LYRIS / GB300-LYRIS).

set -euo pipefail

SQSH_DIR="${SQSH_DIR:-/lustre/fsw/coreai_comparch_trtllm/common/trtllm_sqsh}"
PROPS_FILE="${PROPS_FILE:-${PWD}/jenkins/current_image_tags.properties}"

usage() {
    cat <<EOF
Usage: $(basename "$0") [-v VARIANT] [-k KEY] [-p PROPS] [-d SQSH_DIR]

  -v VARIANT   One of: x86 (default) | gb200 | gb300
  -k KEY       Properties key (default: LLM_DOCKER_IMAGE)
  -p PROPS     Path to properties file (default: \$PWD/jenkins/current_image_tags.properties)
  -d SQSH_DIR  Directory containing sqsh files (default: ${SQSH_DIR})
  -h           Show help

Env overrides: SQSH_DIR, PROPS_FILE
EOF
}

VARIANT="x86"
KEY="LLM_DOCKER_IMAGE"
while getopts ":v:k:p:d:h" opt; do
    case "$opt" in
        v) VARIANT="$OPTARG" ;;
        k) KEY="$OPTARG" ;;
        p) PROPS_FILE="$OPTARG" ;;
        d) SQSH_DIR="$OPTARG" ;;
        h) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
done

[[ -f "$PROPS_FILE" ]] || { echo "error: properties file not found: $PROPS_FILE" >&2; exit 1; }
[[ -d "$SQSH_DIR"  ]] || { echo "error: sqsh dir not found: $SQSH_DIR" >&2; exit 1; }

# Extract the image tag value for KEY from the properties file.
image=$(awk -F= -v k="$KEY" '$1==k {sub(/^[^=]*=/, ""); print; exit}' "$PROPS_FILE")
[[ -n "$image" ]] || { echo "error: key $KEY not found in $PROPS_FILE" >&2; exit 1; }

# The tag's trailing segment is YYYYMMDDhhmm-<buildid>, e.g. 202604011104-12600.
# Timestamp is the 12-digit run (second-to-last dash-separated chunk).
tag="${image##*:}"
ts=$(echo "$tag" | grep -oE '[0-9]{12}-[0-9]+$' | cut -d- -f1)
[[ -n "$ts" ]] || { echo "error: cannot parse timestamp from tag: $tag" >&2; exit 1; }

case "$VARIANT" in
    x86)   suffix=""              ;;
    gb200) suffix="_GB200-LYRIS"  ;;
    gb300) suffix="_GB300-LYRIS"  ;;
    *) echo "error: unknown variant: $VARIANT" >&2; exit 2 ;;
esac

# Match any buildid suffix (sqsh uses a truncated PR number vs. Jenkins).
shopt -s nullglob
matches=("${SQSH_DIR}/tensorrt-llm-${ts}-"*"${suffix}.sqsh")

# Filter out other variants when looking for plain x86.
if [[ "$VARIANT" == "x86" ]]; then
    filtered=()
    for m in "${matches[@]}"; do
        [[ "$m" == *_GB200-LYRIS.sqsh || "$m" == *_GB300-LYRIS.sqsh ]] && continue
        filtered+=("$m")
    done
    matches=("${filtered[@]}")
fi

if (( ${#matches[@]} == 0 )); then
    echo "error: no sqsh found for timestamp ${ts} variant=${VARIANT} in ${SQSH_DIR}" >&2
    exit 1
fi
if (( ${#matches[@]} > 1 )); then
    echo "warn: multiple matches, picking newest:" >&2
    printf '  %s\n' "${matches[@]}" >&2
fi

# Newest by mtime.
ls -1t "${matches[@]}" | head -n1
