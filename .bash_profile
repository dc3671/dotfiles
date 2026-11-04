# Interactive login outside a Slurm job/container: hand over to the user-built
# zsh for this arch (LDAP accounts cannot chsh). Lyris login is x86 and MARS
# login is aarch64, so arch alone cannot tell login from compute. NOZSH=1 keeps bash.
case $(uname -m) in aarch64) __zsh=$HOME/zsh-aarch64/bin/zsh ;; *) __zsh=$HOME/zsh/bin/zsh ;; esac
if [[ $- == *i* ]] && [ -z "${NOZSH}" ] && [ -z "${SLURM_JOB_ID}" ] &&
    [ -z "${ENROOT_PID}${PYXIS_CONTAINER_NAME}${container}" ] &&
    [[ $TERM == xterm* || $TERM == screen* || $TERM == tmux* ]] && [ -x "$__zsh" ]
then
    export SHELL=$__zsh
    if [[ -o login ]]; then
        exec "$__zsh" -l
    else
        exec "$__zsh"
    fi
fi
unset __zsh
[ -e "${HOME}/.bashrc" ] && source "${HOME}/.bashrc"
