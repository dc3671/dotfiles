#!/usr/bin/env bash
# Query SLURM FairShare per project (account) and print accounts ordered by
# priority (highest FairShare first). Useful for picking the best -A/--account
# value before submitting a job.
#
# Examples:
#   query_slurm_ppp.sh                  # local sshare, current user
#   query_slurm_ppp.sh -u xqiao         # local sshare, another user
#   query_slurm_ppp.sh -c lyris         # via ssh to a remote cluster
#   ACCOUNT=$(query_slurm_ppp.sh -t)    # top account only, for scripting
#
# Higher FairShare = higher scheduling priority = job starts sooner.

set -euo pipefail

USER_NAME="${USER}"
CLUSTER=""
FILTER="${SLURM_PPP_FILTER:-coreai}"   # account-name regex, empty = no filter
TOP_ONLY=0

usage() {
    cat <<EOF
Usage: $(basename "$0") [-u USER] [-c CLUSTER] [-f REGEX] [-t]

  -u USER     Slurm user (default: \$USER = ${USER})
  -c CLUSTER  Run sshare via ssh on CLUSTER (default: run locally)
  -f REGEX    Account-name filter regex (default: ${FILTER}; empty = no filter)
  -t          Print only the top account name (no FairShare column)
  -h          Show help

Env overrides: SLURM_PPP_FILTER
EOF
}

while getopts ":u:c:f:th" opt; do
    case "$opt" in
        u) USER_NAME="$OPTARG" ;;
        c) CLUSTER="$OPTARG" ;;
        f) FILTER="$OPTARG" ;;
        t) TOP_ONLY=1 ;;
        h) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
done

run_sshare() {
    if [[ -n "$CLUSTER" ]]; then
        ssh "$CLUSTER" "sshare -u '$USER_NAME' --format=Account,FairShare -P 2>/dev/null"
    else
        command -v sshare >/dev/null || { echo "error: sshare not found in PATH" >&2; exit 1; }
        sshare -u "$USER_NAME" --format=Account,FairShare -P 2>/dev/null
    fi
}

# Pipe through awk for filter + parse + sort. Output is TSV: <account>\t<fairshare>.
rows=$(run_sshare | awk -F'|' -v re="$FILTER" '
    NR==1 { next }                          # skip header
    NF<2 || $2=="" { next }                 # need both fields
    re!="" && $1 !~ re { next }             # account-name filter
    { gsub(/^[ \t]+|[ \t]+$/, "", $1)
      gsub(/^[ \t]+|[ \t]+$/, "", $2)
      printf "%s\t%s\n", $1, $2 }
' | sort -t$'\t' -k2 -rn)

if [[ -z "$rows" ]]; then
    echo "error: no accounts matched for user=${USER_NAME} filter='${FILTER}'" >&2
    exit 1
fi

if (( TOP_ONLY )); then
    printf '%s\n' "$rows" | head -n1 | cut -f1
else
    printf '%-40s  %s\n' "ACCOUNT" "FAIRSHARE"
    printf '%s\n' "$rows" | awk -F'\t' '{ printf "%-40s  %s\n", $1, $2 }'
fi
