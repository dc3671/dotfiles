#!/bin/bash
#
# Bring the claude-hub worker up when the tmux server starts.
#
# Invoked from .tmux.conf via `run-shell -b`. That fires on tmux SERVER START --
# and also on every `prefix + r` (.tmux.conf line 26 is `bind r source-file`),
# so this must NOT be an unconditional `claude-hub-worker restart`: a restart
# tears down whatever hub session is live, and a config reload is a thing you do
# mid-session. Hence the status check below.
#
# What it does do, from `claude-hub-worker list` STATUS (worker script L737-746,
# the three strings are exact):
#     "running"            -> worker is up ON THIS HOST      -> no-op
#     "running (<host>)"   -> up on ANOTHER login node       -> restart = migrate here
#     "not running"        -> down                           -> restart = start
#     no such row          -> not configured on this machine -> no-op
# The migrate case is the point: reconnecting to a different login node should
# pull the worker to the node your tmux is actually on.
#
# Worker name: $CLAUDE_HUB_WORKER if set, else the single configured worker.
# The fallback keeps this file portable across clusters ($HOME is rsynced between
# them) -- on Lyris the one worker is `lyris`, elsewhere it is whatever exists.
# Two or more workers and no env var: it cannot guess, so it logs and stops.
#
# PATH: tmux `run-shell` inherits the tmux server's environment, which on a
# server started outside an interactive shell does NOT carry ~/.local/bin --
# measured: `env -i /bin/sh -c 'command -v claude-hub-worker'` finds nothing.
# So resolve the absolute path first, PATH lookup only as a fallback.

LOG="$HOME/.tmp/claude-hub-boot.log"
mkdir -p "$HOME/.tmp" 2>/dev/null
log() { printf '%s %s\n' "$(date -Is 2>/dev/null)" "$*" >>"$LOG" 2>/dev/null; }

# Compute node / container: the hub worker belongs to the login node. Same
# signals ssh-reconnect.sh uses, minus the slurmstepd case (no tmux there).
[ -n "$SLURM_JOB_ID" ] && exit 0
pgrep -x slurmd &>/dev/null && exit 0
{ [ -n "$ENROOT_PID" ] || [ -n "$PYXIS_CONTAINER_NAME" ] || [ -n "$container" ]; } && exit 0
{ [ -f /.dockerenv ] || [ -f /run/.containerenv ]; } && exit 0

CHW="$HOME/.local/bin/claude-hub-worker"
[ -x "$CHW" ] || CHW=$(command -v claude-hub-worker 2>/dev/null)
[ -x "$CHW" ] || exit 0          # hub not installed on this machine: silent no-op

listing=$("$CHW" list 2>/dev/null) || exit 0

name="${CLAUDE_HUB_WORKER:-}"
if [ -z "$name" ]; then
    # Data rows only: header is NR 1, the ---- rule NR 2, and "No workers." has NF 2.
    mapfile -t names < <(printf '%s\n' "$listing" | awk 'NR>2 && NF>=3 {print $1}')
    if [ "${#names[@]}" -eq 1 ]; then
        name="${names[0]}"
    else
        log "skip: ${#names[@]} workers configured, set CLAUDE_HUB_WORKER to pick one"
        exit 0
    fi
fi

row=$(printf '%s\n' "$listing" | grep -E "^${name}[[:space:]]")
case "$row" in
    "")             log "skip: no worker named '$name' on $(hostname -s)"; exit 0 ;;
    *"not running") reason="was down" ;;
    *"running ("*)  h="${row##*running (}"; reason="migrating from ${h%)}" ;;
    *running)       exit 0 ;;                       # already up here: leave it alone
    *)              log "skip: unparsed status for '$name': $row"; exit 0 ;;
esac

log "restart $name ($reason) on $(hostname -s)"
# --yes: migration prompts for confirmation otherwise, and there is no tty here.
out=$("$CHW" restart --yes "$name" 2>&1); rc=$?
log "  rc=$rc ${out//$'\n'/ | }"
