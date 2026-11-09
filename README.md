# Dotfiles

Shell, tmux, and nvim config for NVIDIA Slurm clusters (Lyris: x86 login + aarch64 compute; MARS: aarch64 login + compute; pyxis containers). `$HOME` is portable across clusters; `~/scratch` is cluster-local.

## Install

```bash
git clone git@github.com:dc3671/dotfiles.git ~/dotfiles
~/dotfiles/install.sh                 # frameworks + symlinks, idempotent
~/dotfiles/install.sh --link-only     # symlinks only (after a $HOME migration)
~/dotfiles/install.sh --tmux-extras   # also fetch tmux net-speed/sysstat
```

Tool binaries are not installed by the script. Unpack them per arch into `$HOME`:

| Tool | x86_64 | aarch64 |
|---|---|---|
| nvim | `~/neovim/bin` | `~/neovim-aarch64/bin` |
| node | `~/node/bin` | `~/node-aarch64/bin` |
| zsh | `~/zsh/bin` | `~/zsh-aarch64/bin` (MARS login; optional) |
| fzf | nvim lazy dir | `~/fzf/bin` |

## Layout

| Path | Role |
|---|---|
| `.bash_profile` | interactive login outside a job/container: exec this arch's zsh if installed (`NOZSH=1` keeps bash); else source `.bashrc` |
| `.zshrc` / `.bashrc` | framework only (oh-my-zsh + p10k / oh-my-bash + ble.sh), then `shell/common.sh` |
| `shell/common.sh` | env, arch-aware PATH, aliases, ulimit, conda (`conda.sh` + `mamba activate`) |
| `.tmux.conf` | prefix `C-x`; boots `scripts/claude-hub-boot.sh` and `scripts/lab-tunnel-boot.sh` |
| `tmux/extras.conf` | net-speed + sysstat; auto-on only without a cgroup pids cap, `TMUX_EXTRAS=1/0` forces |
| `nvim/` | lazy.nvim config, plugins pinned in `nvim/lazy-lock.json` |
| `scripts/` | cluster helpers: `query_slurm_ppp.sh`, `get_current_sqsh.sh`, `check_mem.sh`, `ssh-reconnect.sh`, `park_on_lab.sh` |

## No conda

Shells never install or activate conda; `shell/common.sh` scrubs any inherited `miniforge3*` PATH entry and `CONDA_*` var. Login-node tools go to `~/.local` (`pip install --user`, prebuilt binaries in `~/.local/bin`); jobs use the container's system python or a baked sqsh.
