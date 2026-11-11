# Dotfiles

Shell, tmux, and nvim config for NVIDIA Slurm clusters (Lyris: x86 login + aarch64 compute; MARS: aarch64 login + compute; pyxis containers). `$HOME` is portable across clusters; `~/scratch` is cluster-local.

## Install

```bash
git clone git@github.com:dc3671/dotfiles.git ~/dotfiles
~/dotfiles/install.sh                 # frameworks + symlinks, idempotent
~/dotfiles/install.sh --link-only     # symlinks only (after a $HOME migration)
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
| `.zshrc` / `.bashrc` | framework only (oh-my-zsh + p10k / oh-my-bash + ble.sh), then `shell/common.sh` and `scripts/ssh-reconnect.sh` |
| `shell/common.sh` | env, arch-aware PATH, aliases, ulimit, per-host `TMUX_TMPDIR=~/.tmux/sock.<host>`; scrubs inherited conda PATH and `CONDA_*` vars |
| `.tmux.conf` | prefix `C-x`; boots `scripts/claude-hub-boot.sh` and `scripts/lab-tunnel-boot.sh` |
| `tmux/extras.conf` | `tmux/sysstat.sh` CPU/mem/NIC widget on status-right; fork-free, on by default, `TMUX_EXTRAS=0` disables |
| `nvim/` | lazy.nvim config, plugins pinned in `nvim/lazy-lock.json` |
| `scripts/` | cluster helpers: `query_slurm_ppp.sh` (FairShare-ordered accounts), `get_current_sqsh.sh`, `check_mem.sh` (cgroup memory), `ssh-reconnect.sh` (agent socket), `park_on_lab.sh` (reverse tunnel to the lab hub); tmux boot hooks `claude-hub-boot.sh`, `lab-tunnel-boot.sh` |
