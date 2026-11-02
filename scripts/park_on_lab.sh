#!/usr/bin/env bash
# Park this host's sshd on <hub>:127.0.0.1:<port> so the hub can dial back in.
# The hub cannot reach the cluster (firewalled both ways), so the cluster side
# owns the connection. One port per cluster: lyris 2122, hecate 2222, prenyx
# 2322, bia 2422, poly 2522, ptyche 2622.
#
#   park_on_lab.sh start  -p 2222           # idempotent, safe from a tmux hook
#   park_on_lab.sh start  -p 2222 --steal   # take the hub port from another node
#   park_on_lab.sh status [--check]
#   park_on_lab.sh stop   -p 2222
#   park_on_lab.sh restart -p 2222
#
# Detached background process, not tmux and not systemd --user: `loginctl
# enable-linger` is "Access denied" here so a user unit dies with the last login
# session, and `crontab` is blocked for this user. A setsid orphan survives
# logout because /etc/systemd/logind.conf leaves KillUserProcesses at its `no`
# default. Nothing restarts it after a node reboot — that is the tmux hook's job
# (lab-tunnel-boot.sh).
#
# $HOME is shared between a cluster's login nodes, so the pidfile records the
# host too: "<pid> <host>". A record owned by a different login node is left
# alone while the hub port is still LISTENING — otherwise two nodes fight over
# the same forward and flap. `status` only knows ports that have a pidfile, so a
# hand-started loop squatting a port shows up nowhere: `pgrep -af park_on_lab`.
#
# Node health = GSSAPI login to the node works, the hop mfa_switch_user.sh makes
# after MFA. A node failing it never parks, releases a port it holds, and gets
# its port stolen by the next `start` elsewhere (seen: login-hecate04 reimaged
# with hecate03's host keys, IPA still holding its old ones, GSSAPI denied).
#
# The hub-side sshd pid is recorded on the hub (~/.tmp/tunnels/park_<port>.sshd)
# so --steal kills exactly that connection; lab has no fuser/ss/lsof.
#
# Editing this file while a supervisor is running leaves lustre .nfs* stubs
# behind (silly-rename): stop, edit, start.
set -u
export PATH=${PATH:-}:/usr/bin:/bin

RUNDIR=$HOME/.tmp/claude/tunnels
HUB=lab; PORT=""; CHECK=0; STEAL=0
SELF=$(hostname -s)
CMD=${1:-status}; [ $# -gt 0 ] && shift
while [ $# -gt 0 ]; do
    case "$1" in
        -p|--port) PORT=$2; shift 2 ;;
        -H|--hub)  HUB=$2; shift 2 ;;
        --check)   CHECK=1; shift ;;
        --steal)   STEAL=1; shift ;;
        -h|--help) sed -n '2,13p' "$0"; exit 0 ;;
        *) echo "unknown arg: $1" >&2; exit 2 ;;
    esac
done

paths() {
    [ -n "$PORT" ] || { echo "-p <port> required for '$CMD'" >&2; exit 2; }
    PIDFILE=$RUNDIR/park_${HUB}_${PORT}.pid
    # Per host: two nodes appending to one lustre file interleave and clobber.
    LOG=$RUNDIR/park_${HUB}_${PORT}.${SELF}.log
    HUBREC=.tmp/tunnels/park_${PORT}.sshd     # relative to the hub's $HOME
    mkdir -p "$RUNDIR"
}

record() { cat "$1" 2>/dev/null; }          # "<pid> <host>"
rec_pid()  { set -- $(record "$1"); echo "${1:-}"; }
rec_host() { set -- $(record "$1"); echo "${2:-$SELF}"; }

alive() {  # local pid alive AND still our supervisor, not a recycled pid
    local pid=$1
    [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null &&
        grep -qa "park_on_lab" "/proc/$pid/cmdline" 2>/dev/null
}

hub_listening() {  # is the forward actually up on the hub right now?
    timeout 10 ssh -n -o BatchMode=yes -o ConnectTimeout=6 "$HUB" \
        "timeout 5 bash -c 'cat </dev/null >/dev/tcp/127.0.0.1/$1'" 2>/dev/null
}

gss_ok() {  # can $1 be logged into over GSSAPI? No valid TGT here = cannot judge = yes
    klist -s 2>/dev/null || return 0
    timeout 20 ssh -n -F /dev/null -o BatchMode=yes -o ConnectTimeout=6 \
        -o GSSAPIAuthentication=yes -o PreferredAuthentications=gssapi-with-mic \
        -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR \
        "$1" true 2>/dev/null
}

case "$CMD" in
start|ensure)
    paths
    pid=$(rec_pid "$PIDFILE"); host=$(rec_host "$PIDFILE")
    if [ "$host" = "$SELF" ] && alive "$pid"; then
        echo "already parked: pid $pid on $SELF, $HUB:127.0.0.1:$PORT"; exit 0
    fi
    if ! gss_ok "$(hostname)"; then
        echo "GSSAPI login to $SELF itself fails — a tunnel here is useless, not parking" >&2; exit 1
    fi
    if [ -n "$pid" ] && [ "$host" != "$SELF" ] && [ "$STEAL" = 0 ]; then
        if hub_listening "$PORT"; then
            # Steal only on 3 straight failures: a KDC/DNS blip must not kick a
            # healthy tunnel and its MFA master.
            for i in 1 2 3; do
                if gss_ok "$host"; then
                    echo "port $PORT already served by $host (pid $pid); --steal to move it here"
                    exit 0
                fi
                [ "$i" -lt 3 ] && sleep 5
            done
            echo "holder $host fails GSSAPI login 3x — stealing port $PORT"; STEAL=1
        else
            echo "record from $host is stale (hub port dead), taking over"
        fi
    fi
    # Preflight: hub must answer without a prompt, else the loop spins forever.
    # Retried — a single refusal is usually the hub's MaxStartups throttle after
    # a burst, and a boot hook that gives up on that leaves no tunnel at all.
    ok=0
    for _ in 1 2 3; do
        timeout 10 ssh -n -o BatchMode=yes -o ConnectTimeout=6 "$HUB" true 2>/dev/null && { ok=1; break; }
        sleep 5
    done
    if [ "$ok" = 0 ]; then
        echo "hub '$HUB' unreachable with BatchMode after 3 tries — fix keys/ssh config first" >&2; exit 1
    fi
    if [ "$STEAL" = 1 ]; then
        # Kill the hub-side sshd holding the forward; its tunneled connections, the
        # MFA master included, go with it. The old node's supervisor retries in 10s.
        ssh -n -o BatchMode=yes "$HUB" "read p h <$HUBREC && grep -qa '^sshd' /proc/\$p/cmdline \
            && kill \$p && echo \"killed hub sshd \$p (parked from \$h)\"" 2>/dev/null \
            || echo "no live hub-side record for port $PORT — holder must be stopped by hand" >&2
        sleep 1
    fi
    [ -f "$LOG" ] && [ "$(stat -c%s "$LOG")" -gt 1048576 ] && : >"$LOG"
    setsid nohup "$0" supervise -p "$PORT" -H "$HUB" >>"$LOG" 2>&1 < /dev/null &
    disown 2>/dev/null
    for _ in 1 2 3 4 5 6 7 8 9 10; do
        pid=$(rec_pid "$PIDFILE"); [ "$(rec_host "$PIDFILE")" = "$SELF" ] && alive "$pid" && break
        sleep 1
    done
    if alive "$pid"; then
        echo "parked: pid $pid on $SELF -> $HUB:127.0.0.1:$PORT, log $LOG"
    else
        echo "failed to start; see $LOG" >&2; tail -3 "$LOG" >&2; exit 1
    fi
    ;;
supervise)  # internal: the detached loop itself
    paths
    # Node-local lock, held for this process's lifetime: two starts racing (tmux
    # hook + a manual one) both passed the pidfile check before either wrote it,
    # and the loser then spun 741 times on "remote port forwarding failed for
    # listen port 2222" while overwriting the winner's pidfile. /tmp, not $HOME —
    # lustre flock is not guaranteed, and one supervisor per host is the scope.
    exec 9>"/tmp/park_on_lab_${HUB}_${PORT}.lock"
    flock -n 9 || { echo "$(date -Is) another supervisor holds $HUB:$PORT here — exiting"; exit 0; }
    echo "$$ $SELF" >"$PIDFILE"
    # Only drop the pidfile if it is still ours: a loser must not delete it.
    trap 'kill 0 2>/dev/null; [ "$(rec_pid "$PIDFILE")" = "$$" ] && rm -f "$PIDFILE"; exit 0' TERM INT
    while :; do
        if ! gss_ok "$(hostname)"; then
            echo "$(date -Is) GSSAPI login to self fails — not parking, recheck in 300s"
            sleep 300; continue
        fi
        echo "$(date -Is) connecting -R ${PORT}:localhost:22 $HUB (supervisor $$ on $SELF)"
        # A command instead of -N, to record the hub-side sshd ($PPID there) for
        # --steal. The race loser exits on ExitOnForwardFailure before it runs.
        ssh -T -a -x -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 \
            -o ServerAliveCountMax=3 -o BatchMode=yes \
            -R "${PORT}:localhost:22" "$HUB" \
            "mkdir -p ${HUBREC%/*} && echo \$PPID $SELF >$HUBREC && exec sleep infinity" </dev/null &
        sp=$!
        n=0
        while kill -0 "$sp" 2>/dev/null; do   # health recheck every 300s while parked
            sleep 10; n=$((n + 1))
            # Still up after 10s = forward won. Reclaim the pidfile: a node that
            # held the port meanwhile removes it on its own stop.
            [ "$n" = 1 ] && echo "$$ $SELF" >"$PIDFILE"
            if [ $((n % 30)) = 0 ] && ! gss_ok "$(hostname)"; then
                echo "$(date -Is) GSSAPI login to self broke while parked — releasing the port"
                kill "$sp" 2>/dev/null
            fi
        done
        wait "$sp"; rc=$?
        echo "$(date -Is) ssh exited rc=$rc — retry in 10s"
        sleep 10
    done
    ;;
stop)
    paths
    pid=$(rec_pid "$PIDFILE"); host=$(rec_host "$PIDFILE")
    if [ "$host" != "$SELF" ] && [ -n "$pid" ]; then
        echo "parked from $host, not here — run stop there, or start --steal here"; exit 1
    fi
    if alive "$pid"; then
        kill -TERM "-$pid" 2>/dev/null || kill -TERM "$pid" 2>/dev/null
        for _ in 1 2 3 4 5; do alive "$pid" || break; sleep 1; done
        alive "$pid" && kill -KILL "-$pid" 2>/dev/null
        echo "stopped pid $pid"
    else
        echo "not running"
    fi
    rm -f "$PIDFILE"
    ;;
restart)
    "$0" stop -p "$PORT" -H "$HUB"; exec "$0" start -p "$PORT" -H "$HUB" ;;
status)
    mkdir -p "$RUNDIR"
    shopt -s nullglob
    found=0
    for f in "$RUNDIR"/park_*.pid; do
        found=1
        base=$(basename "$f" .pid); p=${base##*_}; h=${base#park_}; h=${h%_*}
        pid=$(rec_pid "$f"); host=$(rec_host "$f")
        if [ "$host" = "$SELF" ] && alive "$pid"; then
            printf '%-10s port %-6s pid %-8s on %-18s up %s\n' "$h" "$p" "$pid" "$host" \
                "$(ps -o etime= -p "$pid" | tr -d ' ')"
        elif [ "$host" != "$SELF" ]; then
            printf '%-10s port %-6s pid %-8s on %-18s (other login node)\n' "$h" "$p" "$pid" "$host"
        else
            printf '%-10s port %-6s DEAD (stale pidfile %s)\n' "$h" "$p" "$f"
        fi
        if [ "$CHECK" = 1 ]; then
            PORT=$p HUB=$h
            hub_listening "$p" && echo "    hub $h:127.0.0.1:$p LISTENING" \
                              || echo "    hub $h:127.0.0.1:$p NOT listening"
        fi
    done
    [ "$found" = 0 ] && echo "no tunnels registered under $RUNDIR"
    exit 0
    ;;
*)
    echo "usage: $0 {start|stop|restart|status} -p <port> [-H <hub>] [--check] [--steal]" >&2; exit 2 ;;
esac
