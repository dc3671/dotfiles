# x86 login node: hand interactive terminals to the user-built zsh (LDAP accounts
# cannot chsh). NOZSH=1 keeps bash. aarch64 compute/container: stay in bash.
if [[ $- == *i* ]] && [ "$(uname -m)" = "x86_64" ] && [ -z "${NOZSH}" ] &&
    [[ $TERM == xterm* || $TERM == screen* || $TERM == tmux* ]] && [ -x "$HOME/zsh/bin/zsh" ]
then
    export SHELL=$HOME/zsh/bin/zsh
    if [[ -o login ]]; then
        exec "$HOME/zsh/bin/zsh" -l
    else
        exec "$HOME/zsh/bin/zsh"
    fi
elif [ "$(uname -m)" = "aarch64" ] && [ -e "${HOME}/.bashrc" ]; then
    source "${HOME}/.bashrc"
fi
