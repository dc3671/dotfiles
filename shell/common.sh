# Shared by .bashrc and .zshrc: env, PATH, aliases, conda. Must parse in both
# bash and zsh. Shell-specific frameworks (omz/p10k, omb/ble.sh) stay in the rc.

# Inherited PATH / LD_LIBRARY_PATH are kept, not reset: a pyxis container sources
# this file and its image-provided entries (torch/lib, hpcx) must survive.

_arch=${HOSTTYPE:-${CPUTYPE:-$(uname -m)}}   # x86_64 = login node, aarch64 = GB200/GB300 compute

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

# Per-arch tool installs in $HOME. x86 fzf comes from nvim's lazy dir (FZF_BASE).
if [ "$_arch" = aarch64 ]; then
    _prepend PATH "$HOME/neovim-aarch64/bin" "$HOME/node-aarch64/bin" "$HOME/fzf/bin"
else
    _prepend PATH "$HOME/neovim/bin" "$HOME/node/bin" "$HOME/zsh/bin"
fi
_prepend PATH \
    /usr/local/cmake/bin /usr/local/nvidia/bin /usr/local/cuda/bin /usr/local/mpi/bin \
    /usr/local/ucx/bin /opt/amazon/efa/bin /opt/tensorrt/bin
# ~/.local is cluster-local scratch holding x86 binaries: lowest priority.
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
export CONDA_AUTO_ACTIVATE_BASE=false
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

# Two miniforge installs, split by arch: arm64 = compute node/container, x86 =
# login node. Wrong-arch conda = ENOEXEC, then the shell runs conda's python
# source as a script ("import: command not found").
if [ "$_arch" = aarch64 ]; then
    __mf_root="$HOME/scratch/miniforge3"
else
    __mf_root="$HOME/scratch/miniforge3_x86"
fi

# Only my shells + pyxis container shells (pyxis early-injects CONDA_ENV via
# `srun --container-env=CONDA_ENV`). No install for this arch / scratch not
# mounted: skip quietly.
if { _my_shell || [ -n "${CONDA_ENV:-}" ]; } && [ -x "$__mf_root/bin/conda" ]; then
    # conda.sh defines `conda` in pure shell; `conda shell.* hook` spawns python
    # (~0.8s on lustre). Activation goes through mamba (C++): 70ms vs 1.3s.
    . "$__mf_root/etc/profile.d/conda.sh"
    export MAMBA_EXE="$__mf_root/bin/mamba" MAMBA_ROOT_PREFIX="$__mf_root"
    if __mamba_setup="$("$MAMBA_EXE" shell hook --shell "${ZSH_VERSION:+zsh}${BASH_VERSION:+bash}" \
            --root-prefix "$MAMBA_ROOT_PREFIX" 2>/dev/null)"; then
        eval "$__mamba_setup"
        _act=mamba
    else
        alias mamba="$MAMBA_EXE"
        _act=conda
    fi
    unset __mamba_setup

    if [ "${CONDA_ENV:-}" = "null" ]; then
        # opt-out: keep container system trtllm (/usr/local), no conda. Needed for
        # login shells in release images -- `bash -l worker.sh`, `srun --pty bash -l`.
        :
    elif [ -n "${CONDA_ENV:-}" ]; then
        $_act activate "$CONDA_ENV"
    elif _my_shell; then
        # default env, my shells only. batch/pyxis must name CONDA_ENV.
        $_act activate llm
    fi
    unset _act
fi
unset __mf_root _arch
