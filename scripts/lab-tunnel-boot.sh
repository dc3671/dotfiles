#!/bin/bash
#
# Park this login node's sshd on the lab hub when the tmux server starts.
#
# Invoked from .tmux.conf via `run-shell -b`, same slot as claude-hub-boot.sh.
# That also fires on every `prefix + r`, so every step here has to be idempotent
# — park_on_lab.sh's ensure is, and it leaves a node alone after a manual `stop`.
#
# Why the tunnel exists at all: cluster-to-cluster ssh is firewalled and lab
# cannot dial in, so each cluster parks a reverse forward on lab. Details and
# the hub-side ssh config live in the lab-rendezvous-tunnel skill.
#
# PATH: `run-shell` inherits the tmux server's environment, which need not have
# ~/.local/bin; park_on_lab.sh only needs ssh/setsid/ps from /usr/bin.

LOG="$HOME/.tmp/tunnels/boot.log"
mkdir -p "$HOME/.tmp/tunnels" 2>/dev/null
log() { printf '%s %s\n' "$(date -Is 2>/dev/null)" "$*" >>"$LOG" 2>/dev/null; }

# The tunnel belongs to the login node, not to a job or a container.
[ -n "$SLURM_JOB_ID" ] && exit 0
case "$(hostname -s)" in *login*|*vscode*) ;; *) pgrep -x slurmd &>/dev/null && exit 0 ;; esac  # pgrep: ~1s on a login node
{ [ -n "$ENROOT_PID" ] || [ -n "$PYXIS_CONTAINER_NAME" ] || [ -n "$container" ]; } && exit 0
{ [ -f /.dockerenv ] || [ -f /run/.containerenv ]; } && exit 0

PARK="$HOME/dotfiles/scripts/park_on_lab.sh"
[ -x "$PARK" ] || exit 0          # not installed on this machine: silent no-op

# One port per cluster, matching the *-tun blocks in lab:~/.ssh/config.
# PEERS: the cluster's login nodes, kept supervised by each other (standby + reseed).
PEERS=""
case "$(hostname -s)" in
    *lyris*)  PORT=2122; PEERS="login-lyris01 login-lyris02" ;;
    *hecate*) PORT=2222; PEERS="login-hecate02 login-hecate03 login-hecate04" ;;
    *prenyx*) PORT=2322 ;;
    *bia*)    PORT=2422 ;;
    *poly*)   PORT=2522 ;;
    *ptyche*) PORT=2622 ;;
    *) log "skip: no port assigned for $(hostname -s)"; exit 0 ;;
esac

out=$("$PARK" ensure -p "$PORT" --peers "$PEERS" 2>&1); rc=$?
log "ensure -p $PORT on $(hostname -s): rc=$rc ${out//$'\n'/ | }"
