# Nix

## Environment variables

- `NIX_DARWIN_HOST` (required): The hostname for the darwin configuration (e.g., `$(hostname -s)`)
- `NIX_DARWIN_USER` (required): The username for the configuration (e.g., `$(whoami)`)

## NeoVim

NeoVim config (`~/.config/nvim`) is managed manually (AstroNvim), not through nix. Do not add nix modules that write to `~/.config/nvim` — they will overwrite your config on every `darwin-rebuild switch`.

## Starship (Zsh prompt)

Starship is enabled via `programs.starship.enable = true` in `home.nix`, which handles both installation and zsh integration.

To customize, edit `~/.config/starship.toml`. Currently using the `gruvbox-rainbow` preset:

```bash
starship preset gruvbox-rainbow -o ~/.config/starship.toml
```

Browse other presets with `starship preset --list`.

Full configuration reference: https://starship.rs/config/

## Tmux

Tmux config (`~/.tmux.conf`) is managed manually with TPM, not through home-manager's `programs.tmux`. Using `programs.tmux` requires a full Nix rebuild on every config change, which is too slow for iterating on tmux settings. These files are still version-controlled via the bare git repo (`cf` alias).

## Gotchas

> **Warning:** This setup is not guaranteed to succeed end-to-end. It depends on online services (Homebrew, Mac App Store, Nix caches, GitHub) that can fail at any time. If a single step fails, the entire rebuild can abort partway through, leaving the system in a partially-configured state. There is no automatic rollback — you have to fix the failing step and re-run.

- If a single Homebrew cask fails to install, `darwin-rebuild switch` aborts before home-manager activation finishes. This leaves symlinks like `~/.zshrc` pointing at a garbage-collected nix store path (broken shell). Fix: resolve the failing cask and re-run the rebuild command.
- Mac App Store installs via `mas` are particularly unreliable on nix-darwin (frequent `MASError 5`). These are currently disabled in `flake.nix`.

## Bad internet / flights

A full `darwin-rebuild switch` is not viable on bad internet — if any single step fails, the whole rebuild aborts. If you just need to install one thing, bypass nix and use Homebrew directly:

```bash
brew install <formula>
brew install --cask <cask>
```

This won't be managed by nix, but it works on spotty connections since you can just retry the one command that failed. Add it to `flake.nix` later when you're back on stable internet.

## GPG keys

GPG signing key: `0x0541CB6FA5A1DD15` (rsa4096, under primary key `0x5FC80BAF2B00A4F9`).
Primary key + encryption subkey live on a YubiKey. The signing subkey is stored locally on each machine.

### Syncing the signing subkey to a new machine

On the source machine:

```bash
gpg --export-secret-subkeys --armor 0x0541CB6FA5A1DD15 > ~/signing-subkey.asc
gpg --export --armor gpg@tlduck.com > ~/pubkey.asc
```

On the new machine:

```bash
gpg --import pubkey.asc
gpg --import signing-subkey.asc
gpg --edit-key gpg@tlduck.com trust  # set to 5 (ultimate)
```

Then delete the exported files:

```bash
rm -P ~/signing-subkey.asc ~/pubkey.asc
```

- `--export-secret-subkeys` exports only the subkey's secret material, not the primary key's — the new machine can sign but not manage the key
- `--armor` outputs ASCII instead of binary
- `rm -P` securely deletes on macOS

### Key expiry

The signing subkeys expire (currently 2026-11-30). You don't need to generate new keys — just extend the expiry:

```bash
gpg --edit-key gpg@tlduck.com
> key 1        # select the subkey
> expire       # set new expiry
> save
```

After extending, re-export and sync the **public key** to all other machines so they see the updated expiry:

```bash
# source machine
gpg --export --armor gpg@tlduck.com > ~/pubkey.asc
# other machines
gpg --import pubkey.asc
```

The secret key doesn't change — only the public key metadata needs syncing.

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
