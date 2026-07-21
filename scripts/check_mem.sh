#!/bin/bash

# Show current vs. max memory usage for the current user's cgroup (v2).
# Usage:
#   ./check_mem.sh           # one-shot summary
#   ./check_mem.sh -w        # live watch (refresh every 2s)
#   ./check_mem.sh -s        # also print memory.stat breakdown
#   ./check_mem.sh -p        # show peak (high-water mark) instead of current
#   ./check_mem.sh -t [N]    # also list top-N processes by RSS (default 10)
#   ./check_mem.sh -c <path> # use an explicit cgroup directory

set -u

WATCH=0
SHOW_STAT=0
SHOW_PEAK=0
TOP_N=0
CG=""

while [ $# -gt 0 ]; do
    case "$1" in
        -w|--watch) WATCH=1 ;;
        -s|--stat)  SHOW_STAT=1 ;;
        -p|--peak)  SHOW_PEAK=1 ;;
        -t|--top)
            TOP_N=10
            if [ $# -ge 2 ] && [ "${2#-}" = "$2" ] && [ "$2" -eq "$2" ] 2>/dev/null; then
                TOP_N="$2"; shift
            fi ;;
        -c|--cgroup) CG="$2"; shift ;;
        -h|--help)
            sed -n '3,11p' "$0"; exit 0 ;;
        *) echo "Unknown arg: $1" >&2; exit 2 ;;
    esac
    shift
done

if [ -z "$CG" ]; then
    CG="/sys/fs/cgroup/user.slice/user-$(id -u).slice"
fi

if [ ! -r "$CG/memory.current" ] || [ ! -r "$CG/memory.max" ]; then
    echo "Error: cannot read $CG/memory.{current,max}" >&2
    echo "Hint: pass an explicit path with -c <cgroup-dir>" >&2
    exit 1
fi

print_summary() {
    local cur max peak label val
    cur=$(cat "$CG/memory.current")
    max=$(cat "$CG/memory.max")

    if [ "$SHOW_PEAK" -eq 1 ] && [ -r "$CG/memory.peak" ]; then
        peak=$(cat "$CG/memory.peak")
        label="peak"
        val=$peak
    else
        label="used"
        val=$cur
    fi

    if [ "$max" = "max" ]; then
        awk -v v="$val" -v l="$label" \
            'BEGIN{printf "%s: %.2f GiB / max: unlimited\n", l, v/2^30}'
    else
        awk -v v="$val" -v m="$max" -v l="$label" \
            'BEGIN{printf "%s: %.2f GiB / max: %.2f GiB (%.1f%%)\n", l, v/2^30, m/2^30, 100*v/m}'
    fi

    # Reclaimable summary: page cache + reclaimable slab. Kernel can drop these
    # under pressure, so they count toward the cgroup limit but rarely OOM you.
    if [ -r "$CG/memory.stat" ]; then
        awk -v cur="$cur" '
            { s[$1]=$2 }
            END {
                recl = s["file"] + s["slab_reclaimable"]
                unrecl = cur - recl
                printf "  reclaimable: %.2f GiB (page cache + slab) | unreclaimable: %.2f GiB\n", \
                       recl/2^30, unrecl/2^30
            }' "$CG/memory.stat"
    fi

    if [ "$SHOW_STAT" -eq 1 ] && [ -r "$CG/memory.stat" ]; then
        echo "--- memory.stat (top fields) ---"
        awk '$1 ~ /^(anon|file|kernel|sock|shmem|slab|slab_reclaimable|swap)$/ {
                 tag = ($1 == "file" || $1 == "slab_reclaimable") ? "  [reclaimable]" : ""
                 printf "  %-16s %.2f GiB%s\n", $1, $2/2^30, tag
             }' "$CG/memory.stat"
    fi

    if [ "$TOP_N" -gt 0 ]; then
        # Collect PIDs from this cgroup and all descendants (cgroup v2).
        local pids
        pids=$(find "$CG" -name cgroup.procs -readable -exec cat {} + 2>/dev/null \
               | sort -u | tr '\n' ',' | sed 's/,$//')
        if [ -n "$pids" ]; then
            echo "--- top $TOP_N processes by RSS (anon=private, file=mmap'd/reclaimable) ---"
            printf "  %7s  %9s  %9s  %9s  %-15s  %s\n" \
                   "PID" "RSS" "anon" "file" "COMM" "ARGS"
            # Read RssAnon/RssFile from /proc/<pid>/status: file-backed RSS (mmap'd
            # index, PCH, shared libs) is reclaimable and invisible in plain `ps rss`
            # summing. anon is the private footprint that actually pins memory.
            local oldifs="$IFS"; IFS=,
            for pid in $pids; do
                [ -r "/proc/$pid/status" ] || continue
                awk -v pid="$pid" '
                    /^VmRSS:/   {rss=$2}
                    /^RssAnon:/ {anon=$2}
                    /^RssFile:/ {file=$2}
                    /^Name:/    {name=$2}
                    END {
                        if (rss=="") exit
                        printf "%d\t%d\t%d\t%d\t%s\n", rss, anon, file, pid, name
                    }' "/proc/$pid/status"
            done | sort -k1 -nr | head -n "$TOP_N" | while IFS=$'\t' read -r rss anon file pid name; do
                args=$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null | sed 's/ *$//')
                [ ${#args} -gt 70 ] && args="${args:0:67}..."
                awk -v rss="$rss" -v anon="$anon" -v file="$file" -v pid="$pid" \
                    -v name="$name" -v args="$args" 'BEGIN{
                        printf "  %7d  %6.2f GiB  %6.2f GiB  %6.2f GiB  %-15s  %s\n", \
                               pid, rss/2^20, anon/2^20, file/2^20, name, args
                    }'
            done
            IFS="$oldifs"
        fi
    fi
}

if [ "$WATCH" -eq 1 ]; then
    while true; do
        clear
        echo "cgroup: $CG  ($(date +%T))"
        print_summary
        sleep 2
    done
else
    echo "cgroup: $CG"
    print_summary
fi
