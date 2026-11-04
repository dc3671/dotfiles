# Dotfiles

Shell, tmux, and nvim config for NVIDIA Slurm clusters (x86 login nodes, aarch64 GB200/GB300 compute nodes, pyxis containers). `$HOME` is portable across clusters; `~/scratch` is cluster-local.

## Install

```bash
git clone git@github.com:dc3671/dotfiles.git ~/dotfiles
~/dotfiles/install.sh                 # frameworks + symlinks, idempotent
~/dotfiles/install.sh --link-only     # symlinks only (after a $HOME migration)
~/dotfiles/install.sh --tmux-extras   # also fetch tmux net-speed/sysstat
```

Tool binaries are not installed by the script. Unpack them per arch into `$HOME`:

| Tool | x86_64 (login) | aarch64 (compute) |
|---|---|---|
| nvim | `~/neovim/bin` | `~/neovim-aarch64/bin` |
| node | `~/node/bin` | `~/node-aarch64/bin` |
| zsh | `~/zsh/bin` | — (bash) |
| fzf | nvim lazy dir | `~/fzf/bin` |

## Layout

| Path | Role |
|---|---|
| `.bash_profile` | x86 interactive login: exec `~/zsh/bin/zsh` (`NOZSH=1` keeps bash); aarch64: source `.bashrc` |
| `.zshrc` / `.bashrc` | framework only (oh-my-zsh + p10k / oh-my-bash + ble.sh), then `shell/common.sh` |
| `shell/common.sh` | env, arch-aware PATH, aliases, ulimit, conda (`conda.sh` + `mamba activate`) |
| `.tmux.conf` | prefix `C-x`; boots `scripts/claude-hub-boot.sh` and `scripts/lab-tunnel-boot.sh` |
| `tmux/extras.conf` | net-speed + sysstat; auto-on only without a cgroup pids cap, `TMUX_EXTRAS=1/0` forces |
| `nvim/` | lazy.nvim config, plugins pinned in `nvim/lazy-lock.json` |
| `scripts/` | cluster helpers: `query_slurm_ppp.sh`, `get_current_sqsh.sh`, `check_mem.sh`, `ssh-reconnect.sh`, `park_on_lab.sh`, `update_docker_packages.sh` |

## Conda

`CONDA_ENV=<env>` picks the env activated in a new shell (incl. pyxis containers); `CONDA_ENV=null` skips conda; unset activates `llm` in interactive/login shells only. Miniforge roots: `~/scratch/miniforge3` (aarch64), `~/scratch/miniforge3_x86` (x86).
