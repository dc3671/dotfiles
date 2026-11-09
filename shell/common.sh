# Shared by .bashrc and .zshrc: env, PATH, aliases. Must parse in both
# bash and zsh. Shell-specific frameworks (omz/p10k, omb/ble.sh) stay in the rc.

# Inherited PATH / LD_LIBRARY_PATH are kept, not reset: a pyxis container sources
# this file and its image-provided entries (torch/lib, hpcx) must survive.

_arch=${HOSTTYPE:-${CPUTYPE:-$(uname -m)}}   # lyris: x86 login, aarch64 compute; MARS: aarch64 both

# _prepend VAR DIR...: existing DIRs move to the front of VAR, in argument order.
_prepend() {
    local var=$1 d cur pre=
    shift
    eval "cur=\":\${$var:-}:\""
    for d in "$@"; do
        [ -d "$d" ] || continue
        cur=${cur//:$d:/:}
        pre="$pre:$d"
    done
    cur=${cur#:}; cur=${cur%:}; pre=${pre#:}
    eval "export $var=\"\$pre\${pre:+\${cur:+:}}\$cur\""
}

# _drop VAR GLOB...: remove entries of VAR matching any GLOB.
_drop() {
    local var=$1 rest e out= g keep
    shift
    eval "rest=\${$var:-}"
    while [ -n "$rest" ]; do
        e=${rest%%:*}
        case $rest in *:*) rest=${rest#*:} ;; *) rest= ;; esac
        keep=1
        for g in "$@"; do eval "case \$e in $g) keep=0 ;; esac"; done
        [ $keep = 1 ] && out="${out:+$out:}$e"
    done
    if [ -n "$out" ]; then eval "export $var=\"\$out\""; else unset "$var"; fi
}

# sbatch/srun export the x86 login node's env into aarch64 jobs (--export=ALL):
# drop the other arch's tools and libs so they cannot shadow ours.
if [ "$_arch" = aarch64 ]; then
    _drop PATH "$HOME/neovim/bin" "$HOME/node/bin" "$HOME/zsh/bin" \
        "$HOME/.local/share/nvim/lazy/fzf/bin"
    _drop LD_LIBRARY_PATH '*/x86_64-linux-gnu'
else
    _drop PATH "$HOME/*-aarch64/bin" "$HOME/fzf/bin"
    _drop LD_LIBRARY_PATH '*/aarch64-linux-gnu'
fi
# No conda: scrub a conda env inherited from an old shell or a submitter's env.
_drop PATH '*/miniforge3*/*' '*/miniconda3*/*' '*/anaconda3*/*'
unset CONDA_ENV CONDA_PREFIX CONDA_SHLVL CONDA_DEFAULT_ENV CONDA_PROMPT_MODIFIER \
    CONDA_EXE CONDA_PYTHON_EXE _CE_CONDA _CE_M _CONDA_EXE _CONDA_ROOT MAMBA_EXE MAMBA_ROOT_PREFIX
for _i in 1 2 3 4 5 6 7 8 9; do unset CONDA_PREFIX_$_i; done
unset _i

# Per-arch tool installs in $HOME. x86 fzf comes from nvim's lazy dir (FZF_BASE).
if [ "$_arch" = aarch64 ]; then
    _prepend PATH "$HOME/neovim-aarch64/bin" "$HOME/node-aarch64/bin" "$HOME/zsh-aarch64/bin" \
        "$HOME/fzf/bin"
else
    _prepend PATH "$HOME/neovim/bin" "$HOME/node/bin" "$HOME/zsh/bin"
fi
_prepend PATH \
    /usr/local/cmake/bin /usr/local/nvidia/bin /usr/local/cuda/bin /usr/local/mpi/bin \
    /usr/local/ucx/bin /opt/amazon/efa/bin /opt/tensorrt/bin
# ~/.local is cluster-local scratch, built for that cluster's login arch: lowest priority.
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$PATH:$HOME/.local/bin" ;; esac

_prepend LD_LIBRARY_PATH \
    /opt/nvidia/nvda_nixl/lib/x86_64-linux-gnu /opt/nvidia/nvda_nixl/lib64 /usr/local/ucx/lib \
    /usr/local/cuda/compat/lib /usr/local/nvidia/lib /usr/local/nvidia/lib64 \
    /usr/local/cuda/lib64 /usr/local/tensorrt/lib
_d="$HOME/.local/lib/$_arch-linux-gnu"   # libpcsclite for ~/.local/bin CLIs
case ":$LD_LIBRARY_PATH:" in
    *":$_d:"*) ;;
    *) [ -d "$_d" ] && export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}$_d" ;;
esac
unset _d

# Forced so a laptop's LC_CTYPE=UTF-8 (invalid on Linux) cannot leak in; images
# without en_US get C.UTF-8 instead of setlocale warnings.
if locale -a 2>/dev/null | grep -qix 'en_US.utf-\{0,1\}8'; then _loc=en_US.UTF-8; else _loc=C.UTF-8; fi
export LC_ALL=$_loc LANG=$_loc
unset _loc

# Keep tmux's TERM (tmux-256color); fall back only where its terminfo is missing.
command -v tput >/dev/null 2>&1 && ! tput -T "${TERM:-dumb}" longname >/dev/null 2>&1 &&
    export TERM=xterm-256color

export SQUEUE_FORMAT="%.18i %.9P %.40j %.10u %.2t %.10M %.6D %R"
export EDITOR=nvim
umask 022

# Login nodes cap the user cgroup (lyris: pids.max 640); mirror it in RLIMIT_NPROC
# so worker pools size down instead of hitting EAGAIN. Compute nodes: no cap.
_pids_max=$(cat "/sys/fs/cgroup/user.slice/user-$(id -u).slice/pids.max" 2>/dev/null)
case $_pids_max in
    ''|max) ulimit -u 131072 2>/dev/null ;;
    *) ulimit -u "$_pids_max" 2>/dev/null ;;
esac
ulimit -n "$(ulimit -Hn)" 2>/dev/null
unset _pids_max

alias vi=nvim
alias cp="cp -r"
alias rm="rm -r"
alias mkdir="mkdir -p"
alias ll="ls -lh"
alias salloc="SHELL=/bin/bash salloc"
alias claude='claude --model "opus" --effort high'

# Interactive or login shell; an ssh command shell (rsync/scp/git-over-ssh) is
# neither but still sources .bashrc. .zshrc is interactive-only.
if [ -n "$ZSH_VERSION" ]; then
    _my_shell() { return 0; }
else
    _my_shell() { [[ $- == *i* ]] || shopt -q login_shell; }
fi

unset _arch
