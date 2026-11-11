#!/usr/bin/env bash
# Park this host's sshd on <hub>:127.0.0.1:<port> so the hub can dial back in.
# The hub cannot reach the cluster (firewalled both ways), so the cluster side
# owns the connection. One port per cluster: lyris 2122, hecate 2222, prenyx
# 2322, bia 2422, poly 2522, ptyche 2622, rhea 2722.
#
#   park_on_lab.sh start   -p 2222 [--peers "h1 h2"]  # by hand; clears stop's off-mark
#   park_on_lab.sh ensure  -p 2222 [--peers "h1 h2"]  # tmux hook, peer seed; honours it
#   park_on_lab.sh start   -p 2222 --steal            # take the hub port from another node
#   park_on_lab.sh status  [--check]
#   park_on_lab.sh stop    -p 2222                    # this node only; sets the off-mark
#   park_on_lab.sh restart -p 2222 [--peers "h1 h2"]
#   park_on_lab.sh krb-tidy                           # prune KCM, fix primary, renew
#
# Detached background process, not tmux and not systemd --user: `loginctl
# enable-linger` is "Access denied" here so a user unit dies with the last login
# session, and `crontab` is blocked for this user. A setsid orphan survives
# logout because /etc/systemd/logind.conf leaves KillUserProcesses at its `no`
# default. A reboot kills it; a peer (--peers) or the tmux hook brings it back.
#
# Every login node runs one supervisor: one holds the port, the rest stand by.
# A standby takes over when the forward stops answering with an sshd banner: at
# once if the hub listener is gone, after 3 misses 60s apart if it lingers (holder
# died hard). Login nodes reboot one at a time (hecate 2026-11: 04 on 11-04, 03
# on 11-05, 02 up since 10-14), so some standby is normally alive.
#
# --peers: each supervisor runs `ensure` on every peer over GSSAPI every 10 min,
# so a rebooted login node rejoins without a login. The TGT is delegated only to
# a peer without a valid one, and lasts until renew-until: 7 days after the MFA
# login that issued it. `stop` sets an off-mark that `ensure` honours.
#
# KCM caps a uid at 64 caches and each delegated login adds one and makes it the
# primary. At the cap every write fails (`Internal credentials cache error`), so
# renewals stop and the primary can be left empty (hecate 2026-11-06: delegating
# every 10 min filled 3 nodes in ~5h). krb_tidy runs every 10 min to prevent it.
#
# $HOME is shared between login nodes: park_<hub>_<port>.pid names the holder
# ("<pid> <host>"), park_<hub>_<port>.<host>.node each node's supervisor. One
# supervisor per node: supervise holds a per-host flock here (lustre mounted with
# `flock`), start tests it. Never /tmp: pam_namespace gives each
# ssh session its own, so a /tmp lock let peer seeds stack 133 supervisors on 3
# nodes in 4 min (2026-11-05). A hard-rebooted node's lock lingers until lustre
# evicts it; the next reseed retries.
#
# Node health = GSSAPI login to the node works, the hop mfa_switch_user.sh makes
# after MFA. A node failing it on itself never parks (seen: login-hecate04
# reimaged with hecate03's host keys, IPA still holding its old ones); a standby
# that sees the holder fail it 2 rounds running steals the port. Single probes
# fail transiently (8 releases in 13h on hecate03): never act on one.
#
# Before a health steal, the hub's MFA master (if any) runs `true` through the
# holder; success vetoes the steal, which would kill that master and cost an MFA.
# 2026-11-07: a ~1 min sshd auth stall on hecate03 hit both rounds, 04 stole.
#
# The hub-side sshd pid is recorded on the hub (~/.tmp/tunnels/park_<port>.sshd)
# so a steal kills exactly that connection; lab has no fuser/ss/lsof.
#
# Never edit this file in place while supervisors run (bash reads it lazily):
# write a new file and mv it over; the old inode lingers as an .nfs* stub.
set -u
export PATH=${PATH:-}:/usr/bin:/bin

SCRIPT=$(readlink -f "$0")
RUNDIR=$HOME/.tmp/tunnels
HUB=lab; PORT=""; CHECK=0; STEAL=0; PEERS=""
SELF=$(hostname -s)
CMD=${1:-status}; [ $# -gt 0 ] && shift
while [ $# -gt 0 ]; do
    case "$1" in
        -p|--port) PORT=$2; shift 2 ;;
        -H|--hub)  HUB=$2; shift 2 ;;
        --peers)   PEERS=$2; shift 2 ;;
        --check)   CHECK=1; shift ;;
        --steal)   STEAL=1; shift ;;
        -h|--help) sed -n '2,13p' "$0"; exit 0 ;;
        *) echo "unknown arg: $1" >&2; exit 2 ;;
    esac
done

paths() {
    [ -n "$PORT" ] || { echo "-p <port> required for '$CMD'" >&2; exit 2; }
    PIDFILE=$RUNDIR/park_${HUB}_${PORT}.pid            # holder: "<pid> <host>"
    NODEFILE=$RUNDIR/park_${HUB}_${PORT}.${SELF}.node  # this node's supervisor pid
    OFFMARK=$RUNDIR/park_${HUB}_${PORT}.${SELF}.off
    LOCK=$RUNDIR/park_${HUB}_${PORT}.${SELF}.lock
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

running_here() { ! flock -n "$LOCK" true 2>/dev/null; }  # 5ms; pgrep -f scans ~4k login-node procs, ~1s

hub_listening() {  # is the forward actually up on the hub right now?
    timeout 10 ssh -n -o BatchMode=yes -o ConnectTimeout=6 "$HUB" \
        "timeout 5 bash -c 'cat </dev/null >/dev/tcp/127.0.0.1/$1'" 2>/dev/null
}

hub_state() {  # 0 sshd banner through the forward, 1 listener but no banner, 2 hub unreachable, 3 no listener
    local out
    out=$(timeout 20 ssh -n -o BatchMode=yes -o ConnectTimeout=6 "$HUB" \
        "printf ok:; timeout 8 bash -c 'exec 3<>/dev/tcp/127.0.0.1/$PORT || { printf closed; exit; }; head -c 4 <&3'" 2>/dev/null)
    case "$out" in ok:SSH-) return 0 ;; ok:closed) return 3 ;; ok:*) return 1 ;; *) return 2 ;; esac
}

hub_holder() { ssh -n -o BatchMode=yes -o ConnectTimeout=6 "$HUB" "cat $HUBREC" 2>/dev/null; }  # "<pid> <host>"

kill_hub_sshd() {  # only if the record still names $1: a racing standby's fresh sshd must survive
    ssh -n -o BatchMode=yes "$HUB" "read p h <$HUBREC && [ \"\$p\" = '$1' ] && grep -qa '^sshd' /proc/\$p/cmdline \
        && kill \$p && echo \"killed hub sshd \$p (parked from \$h)\"" 2>/dev/null
}

hub_master_ok() {  # 0 hub's MFA master for $PORT runs a command, 1 it fails, 2 no master
    local out  # 90s: outlasts the ~1 min auth stalls seen on hecate03
    out=$(timeout 100 ssh -n -o BatchMode=yes -o ConnectTimeout=6 "$HUB" \
        "for s in ~/.ssh/cm-*@127.0.0.1:$PORT; do [ -S \"\$s\" ] && ssh -S \"\$s\" -O check x 2>/dev/null || continue
         timeout 90 ssh -S \"\$s\" -o ControlMaster=no -o BatchMode=yes x true </dev/null >/dev/null 2>&1 && echo ok || echo fail; exit
         done; echo none" 2>/dev/null)
    case "$out" in ok) return 0 ;; fail) return 1 ;; *) return 2 ;; esac
}

gss_ok() {  # can $1 be logged into over GSSAPI? No valid TGT here = cannot judge = yes
    klist -s 2>/dev/null || return 0
    local i err rc
    for i in 1 2 3; do  # one failed probe is routinely a blip, never act on it
        err=$(timeout 20 ssh -n -F /dev/null -o BatchMode=yes -o ConnectTimeout=6 \
            -o GSSAPIAuthentication=yes -o PreferredAuthentications=gssapi-with-mic \
            -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR \
            "$1" true 2>&1 >/dev/null) && return 0
        rc=$?
        echo "$(date -Is) gss_ok $1 try $i: rc=$rc ${err//$'\n'/ | }" >&2
        [ "$i" -lt 3 ] && sleep 5
    done
    return 1
}

krb_tidy() {  # keep only a valid primary KCM cache, renewed; sessions don't pin KRB5CCNAME
    local c p
    if ! klist -s 2>/dev/null; then  # kswitch also fails at the cap: prune expired first
        for c in $(klist -l 2>/dev/null | awk '/KCM:/ && /\(Expired\)/ {print $2}'); do
            kdestroy -c "$c" 2>/dev/null; done
        c=$(klist -l 2>/dev/null | awk '/KCM:/ && !/\(Expired\)/ {print $2; exit}')
        [ -n "$c" ] && kswitch -c "$c" 2>/dev/null
    fi
    klist -s 2>/dev/null || return 0  # nothing valid: leave it for a login to fix
    p=$(klist 2>/dev/null | sed -n 's/^Ticket cache: //p')
    for c in $(klist -l 2>/dev/null | awk '/KCM:/ {print $2}'); do
        [ "$c" = "$p" ] || kdestroy -c "$c" 2>/dev/null; done
    # Only after the prune: at the cap, kinit -R empties the cache and then fails to save.
    kinit -R 2>/dev/null || echo "$(date -Is) krb_tidy: kinit -R failed"
}

seed_peers() {  # `ensure` on each peer; quiet when it already runs or is off
    local h out rc d
    for h in $PEERS; do
        [ "$h" = "$SELF" ] && continue
        # Delegation lands the TGT in the peer's KCM, which outlives the session
        # (GSSAPICleanupCredentials no): a seeded peer can seed in turn. rc 42 =
        # the peer has no valid TGT, retry with delegation.
        for d in no yes; do
            out=$(timeout 60 ssh -n -F /dev/null -o BatchMode=yes -o ConnectTimeout=6 \
                -o GSSAPIAuthentication=yes -o PreferredAuthentications=gssapi-with-mic \
                -o GSSAPIDelegateCredentials=$d \
                -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR \
                "$h" "[ $d = yes ] || klist -s || exit 42; $SCRIPT krb-tidy; $SCRIPT ensure -p $PORT -H $HUB --peers '$PEERS'" 2>&1)
            rc=$?
            [ "$rc" = 42 ] || break
        done
        case "$out" in *"already running"*|*"off on"*) ;;
            *) echo "$(date -Is) seed $h (delegate=$d rc=$rc): ${out//$'\n'/ | }" ;; esac
    done
}

case "$CMD" in
start|ensure)
    paths
    if [ "$CMD" = ensure ] && [ -e "$OFFMARK" ]; then
        echo "off on $SELF (stopped by hand) — 'start' to re-enable"; exit 0
    fi
    rm -f "$OFFMARK"
    if running_here; then
        pid=$(cat "$NODEFILE" 2>/dev/null)
        if [ "$STEAL" = 0 ]; then
            echo "already running here: supervisor ${pid:-?} on $SELF"; exit 0
        fi
        # A standby here would lose the race to the old holder's 10s retry; relaunch with --steal.
        alive "$pid" && kill -TERM "-$pid" 2>/dev/null
        for _ in 1 2 3 4 5; do running_here || break; sleep 1; done
    fi
    if ! gss_ok "$(hostname)"; then
        echo "GSSAPI login to $SELF itself fails — a tunnel here is useless, not parking" >&2; exit 1
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
    [ -f "$LOG" ] && [ "$(stat -c%s "$LOG")" -gt 1048576 ] && : >"$LOG"
    rm -f "$NODEFILE"
    sargs=(supervise -p "$PORT" -H "$HUB" --peers "$PEERS")
    [ "$STEAL" = 1 ] && sargs+=(--steal)
    setsid nohup "$SCRIPT" "${sargs[@]}" >>"$LOG" 2>&1 < /dev/null &
    disown 2>/dev/null
    for _ in 1 2 3 4 5 6 7 8 9 10; do
        pid=$(cat "$NODEFILE" 2>/dev/null); alive "$pid" && break
        sleep 1
    done
    if alive "$pid"; then
        echo "supervisor pid $pid on $SELF for $HUB:127.0.0.1:$PORT (holder or standby: status), log $LOG"
    else
        echo "failed to start; see $LOG" >&2; tail -3 "$LOG" >&2; exit 1
    fi
    ;;
supervise)  # internal: the detached loop itself
    paths
    exec 9>"$LOCK"
    flock -n 9 || { echo "$(date -Is) another supervisor holds $HUB:$PORT here — exiting"; exit 0; }
    echo "$$" >"$NODEFILE"
    # Only drop files that are still ours: a successor may have rewritten them.
    trap 'kill 0 2>/dev/null; [ "$(rec_pid "$PIDFILE")" = "$$" ] && rm -f "$PIDFILE"
          [ "$(cat "$NODEFILE" 2>/dev/null)" = "$$" ] && rm -f "$NODEFILE"; exit 0' TERM INT
    ( sleep 30; while kill -0 $$ 2>/dev/null; do
        krb_tidy; [ -n "$PEERS" ] && seed_peers; sleep 600; done ) &
    misses=0; gfails=0; n=0; role=""
    while :; do
        take=0
        if [ "$STEAL" = 1 ]; then
            STEAL=0; take=1
            set -- $(hub_holder)
            [ -n "${1:-}" ] && [ "${2:-}" != "$SELF" ] && kill_hub_sshd "$1" | sed "s/^/$(date -Is) steal: /"
        else
            hub_state; st=$?
            case $st in
            0)  misses=0; n=$((n + 1))
                if [ "$role" != standby ]; then
                    role=standby; echo "$(date -Is) standby: $HUB:$PORT answered by $(hub_holder | cut -d' ' -f2)"
                fi
                if [ $((n % 10)) = 0 ]; then  # holder health, ~10 min
                    set -- $(hub_holder)
                    if [ -n "${2:-}" ] && [ "$2" != "$SELF" ] && ! gss_ok "$2"; then
                        gfails=$((gfails + 1)); echo "$(date -Is) holder $2 fails GSSAPI login ($gfails/2)"
                        if [ "$gfails" -ge 2 ]; then
                            gfails=0
                            hub_master_ok; mst=$?
                            if [ "$mst" = 0 ]; then
                                echo "$(date -Is) holder $2: hub MFA master still works through it — not stealing"
                            else
                                echo "$(date -Is) holder $2: hub MFA master $([ "$mst" = 1 ] && echo fails || echo absent) — stealing"
                                take=1; kill_hub_sshd "$1" | sed "s/^/$(date -Is) steal: /"
                            fi
                        fi
                    else
                        gfails=0
                    fi
                fi ;;
            1)  misses=$((misses + 1))
                echo "$(date -Is) $HUB:$PORT listening but no sshd banner ($misses/3)"
                if [ "$misses" -ge 3 ]; then
                    misses=0; take=1
                    set -- $(hub_holder)
                    [ -n "${1:-}" ] && kill_hub_sshd "$1" | sed "s/^/$(date -Is) stale: /"
                fi ;;
            2)  echo "$(date -Is) hub $HUB unreachable — recheck in 60s" ;;
            3)  misses=0; take=1 ;;
            esac
        fi
        [ "$take" = 1 ] || { sleep 60; continue; }
        if ! gss_ok "$(hostname)"; then
            echo "$(date -Is) GSSAPI login to self fails — not parking, recheck in 300s"
            sleep 300; continue
        fi
        role=holder
        echo "$(date -Is) connecting -R ${PORT}:localhost:22 $HUB (supervisor $$ on $SELF)"
        # A command instead of -N, to record the hub-side sshd ($PPID there) for
        # steals. The race loser exits on ExitOnForwardFailure before it runs.
        # Polls $PPID: `exec sleep infinity` outlived its killed sshd (no tty, no HUP).
        ssh -T -a -x -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 \
            -o ServerAliveCountMax=3 -o BatchMode=yes \
            -R "${PORT}:localhost:22" "$HUB" \
            "mkdir -p ${HUBREC%/*} && echo \$PPID $SELF >$HUBREC && while kill -0 \$PPID 2>/dev/null; do sleep 60; done" </dev/null &
        sp=$!
        # Still up after 10s = forward won.
        sleep 10
        kill -0 "$sp" 2>/dev/null && echo "$$ $SELF" >"$PIDFILE"
        wait "$sp"; rc=$?
        echo "$(date -Is) ssh exited rc=$rc — retry in 10s"
        sleep 10
    done
    ;;
stop)
    paths
    : >"$OFFMARK"
    pid=$(cat "$NODEFILE" 2>/dev/null)
    # Supervisors from before the standby design wrote only the holder record.
    [ -z "$pid" ] && [ "$(rec_host "$PIDFILE")" = "$SELF" ] && pid=$(rec_pid "$PIDFILE")
    if alive "$pid"; then
        kill -TERM "-$pid" 2>/dev/null || kill -TERM "$pid" 2>/dev/null
        for _ in 1 2 3 4 5; do alive "$pid" || break; sleep 1; done
        alive "$pid" && kill -KILL "-$pid" 2>/dev/null
        echo "stopped pid $pid on $SELF"
    else
        echo "not running on $SELF"
    fi
    rm -f "$NODEFILE"
    [ "$(rec_host "$PIDFILE")" = "$SELF" ] && rm -f "$PIDFILE"
    echo "off-mark set: peers and the tmux hook leave $SELF alone until 'start'"
    ;;
krb-tidy)
    krb_tidy; exit 0 ;;
restart)
    "$SCRIPT" stop -p "$PORT" -H "$HUB"; exec "$SCRIPT" start -p "$PORT" -H "$HUB" --peers "$PEERS" ;;
status)
    mkdir -p "$RUNDIR"
    shopt -s nullglob
    found=0
    for f in "$RUNDIR"/park_*.pid; do
        found=1
        base=$(basename "$f" .pid); p=${base##*_}; h=${base#park_}; h=${h%_*}
        printf '%-10s port %-6s holder pid %-8s on %s\n' "$h" "$p" "$(rec_pid "$f")" "$(rec_host "$f")"
        for n in $(for x in "$RUNDIR"/park_${h}_${p}.*.node "$RUNDIR"/park_${h}_${p}.*.off; do
                       x=${x%.*}; echo "${x##*.}"; done | sort -u); do
            pid=$(cat "$RUNDIR/park_${h}_${p}.$n.node" 2>/dev/null)
            if [ -e "$RUNDIR/park_${h}_${p}.$n.off" ]; then st=OFF
            elif [ "$n" != "$SELF" ]; then st="(other login node)"
            elif alive "$pid"; then st="up $(ps -o etime= -p "$pid" | tr -d ' ')"
            else st=DEAD; fi
            printf '    %-18s supervisor %-8s %s\n' "$n" "${pid:--}" "$st"
        done
        if [ "$CHECK" = 1 ]; then
            PORT=$p HUB=$h
            hub_state
            case $? in
                0) echo "    hub $h:127.0.0.1:$p sshd answers" ;;
                1) echo "    hub $h:127.0.0.1:$p LISTENING but no sshd banner" ;;
                2) echo "    hub $h unreachable" ;;
                3) echo "    hub $h:127.0.0.1:$p NOT listening" ;;
            esac
        fi
    done
    [ "$found" = 0 ] && echo "no tunnels registered under $RUNDIR"
    exit 0
    ;;
*)
    echo "usage: $0 {start|ensure|stop|restart|status|krb-tidy} -p <port> [-H <hub>] [--peers \"h1 h2\"] [--check] [--steal]" >&2; exit 2 ;;
esac
