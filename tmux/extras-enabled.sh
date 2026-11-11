#!/bin/sh
# Exit 0 when .tmux.conf should load tmux/extras.conf. tmux/sysstat.sh forks
# nothing, so it is on by default even under a cgroup pids cap; TMUX_EXTRAS=0 disables.
[ "${TMUX_EXTRAS:-1}" != 0 ]
