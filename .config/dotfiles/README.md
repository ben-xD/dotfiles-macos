# Nix

## Environment variables

- `NIX_DARWIN_HOST` (required): The hostname for the darwin configuration (e.g., `$(hostname -s)`)
- `NIX_DARWIN_USER` (required): The username for the configuration (e.g., `$(whoami)`)

## NeoVim

NeoVim config (`~/.config/nvim`) is managed manually (AstroNvim), not through nix. Do not add nix modules that write to `~/.config/nvim` — they will overwrite your config on every `darwin-rebuild switch`.

## Tmux

Tmux config (`~/.tmux.conf`) is managed manually with TPM, not through home-manager's `programs.tmux`. Using `programs.tmux` requires a full Nix rebuild on every config change, which is too slow for iterating on tmux settings. These files are still version-controlled via the bare git repo (`cf` alias).

## Gotchas

- If a single Homebrew cask fails to install, `darwin-rebuild switch` aborts before home-manager activation finishes. This leaves symlinks like `~/.zshrc` pointing at a garbage-collected nix store path (broken shell). Fix: resolve the failing cask and re-run the rebuild command.

## Useful commands

- rebuild flake: `sudo NIX_DARWIN_HOST="$(hostname -s)" NIX_DARWIN_USER="$(whoami)" darwin-rebuild switch --flake ~/.config/dotfiles --impure`
  - impure because we're passing env vars
- fresh machine setup: `NIX_DARWIN_USER="$(whoami)" nix run ~/.config/dotfiles#setup --impure`
  - initial provisioning (SSH keys, TPM, etc.). Not run during rebuilds. Safe to re-run on existing machines — all steps are guarded or idempotent.
- completely update dependencies: `nix flake update`

## LocalHostName, hostname and ComputerName

```bash
scutil --get ComputerName
scutil --get LocalHostName
hostname -s
```

To set all hostnames to a specific value:

```bash
NAME="EXAMPLE_MACHINE_NAME"
sudo scutil --set ComputerName "$NAME"
sudo scutil --set LocalHostName "$NAME"
sudo scutil --set HostName "$NAME"
```
