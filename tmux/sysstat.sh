#!/usr/bin/env bash
# tmux status widget: CPU / mem / default-route NIC rate, one line, no forks
# (bash builtins only), so it is cheap under a cgroup pids cap.
#
# CPU and NIC are deltas against the previous call, kept in a per-user state
# file under $XDG_RUNTIME_DIR; the first call on a host prints 0.
#
#   set -g status-right "#(~/dotfiles/tmux/sysstat.sh) ..."

state=${XDG_RUNTIME_DIR:-/tmp}/tmux-sysstat.$UID

# Helpers set REPLY instead of echoing: $(...) would fork a subshell.
# color VALUE MEDIUM HIGH -> tmux fg color
color() { REPLY=green; (( $1 >= $2 )) && REPLY=yellow; (( $1 >= $3 )) && REPLY=red; }

# rate BYTES_PER_SEC -> "12.3M" (one decimal, K/M/G)
rate() {
    local b=$1 u=K d=1024
    (( b >= 1048576 )) && { u=M; d=1048576; }
    (( b >= 1073741824 )) && { u=G; d=1073741824; }
    local t=$(( b * 10 / d ))
    REPLY=$(( t / 10 )).$(( t % 10 ))$u
}

now=$EPOCHREALTIME; now=${now/./}; now=$(( 10#$now / 1000 ))   # ms

read -r _ u n s i w q sq st _ < /proc/stat
busy=$(( u + n + s + q + sq + st )); total=$(( busy + i + w ))

while read -r k v _; do
    case $k in MemTotal:) mt=$v ;; MemAvailable:) ma=$v; break ;; esac
done < /proc/meminfo
mem=$(( (mt - ma) * 100 / mt ))

# default-route interface: /proc/net/route row with destination 00000000
dev=
while read -r ifc dst _; do [[ $dst == 00000000 ]] && { dev=$ifc; break; }; done < /proc/net/route
rx=0 tx=0
if [[ -n $dev ]]; then
    while IFS=: read -r ifc rest; do
        [[ ${ifc// /} == "$dev" ]] || continue
        read -r rx _ _ _ _ _ _ _ tx _ <<< "$rest"; break
    done < /proc/net/dev
fi

cpu=0 up=0 down=0
if read -r pnow pbusy ptotal prx ptx 2>/dev/null < "$state"; then
    (( total > ptotal )) && cpu=$(( (busy - pbusy) * 100 / (total - ptotal) ))
    dt=$(( now - pnow ))
    (( dt > 0 && rx >= prx && tx >= ptx )) && { down=$(( (rx - prx) * 1000 / dt )); up=$(( (tx - ptx) * 1000 / dt )); }
fi
echo "$now $busy $total $rx $tx" > "$state"

f='#[fg=#c5cdd9]'
rate $up; o="$f↑$REPLY "; rate $down; o+="↓$REPLY "
color $cpu 30 80; o+="${f}C:#[fg=$REPLY]$cpu% "
color $mem 75 90; o+="${f}M:#[fg=$REPLY]$mem%"
printf '%s' "$o"
