#!/bin/bash
# source: http://tychoish.com/rhizome/9-awesome-ssh-tricks/
ssh-reagent() {
	for agent in /tmp/ssh-*/agent.*; do
		export SSH_AUTH_SOCK=$agent
		if ssh-add -l >/dev/null 2>&1; then
			echo Found working SSH Agent:
			ssh-add -l
			return
		fi
	done
	echo "Cannot find ssh agent - maybe you should reconnect and forward it?"
}
ssh-reagent

# reset DISPLAY
export DISPLAY="$(tmux show-env | sed -n 's/^DISPLAY=//p')"
