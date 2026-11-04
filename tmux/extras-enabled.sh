#!/bin/sh
# Exit 0 when .tmux.conf should load tmux/extras.conf (net-speed + sysstat).
# Both fork scripts every status-interval, so the default is on only where the
# user cgroup has no pids cap (lyris login: pids.max 640). TMUX_EXTRAS=1/0 forces.
d=$HOME/.tmux/plugins
[ -f "$d/tmux-net-speed/net_speed.tmux" ] && [ -f "$d/tmux-plugin-sysstat/sysstat.tmux" ] || exit 1
case ${TMUX_EXTRAS:-auto} in 1) exit 0 ;; 0) exit 1 ;; esac
[ "$(cat "/sys/fs/cgroup/user.slice/user-$(id -u).slice/pids.max" 2>/dev/null || echo max)" = max ]
