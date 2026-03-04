{ nixpkgs, username }:
  system: let
    pkgs = import nixpkgs { inherit system; };
    userHome = "/Users/${username}";
    githubSshKey = "${userHome}/.ssh/github";
    browser = "brave browser";
    app = pkgs.writeShellApplication {
      name = "setup";
      runtimeInputs = with pkgs; [ git openssh coreutils ];
      text = ''
        # Detect if we're running over SSH (no GUI available)
        is_ssh() { [ -n "''${SSH_CLIENT:-}" ] || [ -n "''${SSH_TTY:-}" ]; }

        # --- Headless steps (always run) ---

        echo "set up: GitHub SSH key"
        if test -f "${githubSshKey}"; then
          echo "skip: github ssh key already exists"
        else
          echo "create: creating GitHub ssh key with no passphrase."
          ssh-keygen -f "${githubSshKey}" -N ""
          if is_ssh; then
            echo "Public key (add to https://github.com/settings/keys):"
            cat "${githubSshKey}.pub"
          else
            echo "Add a new SSH key to GitHub. The public key is in your clipboard."
            open -a "${browser}" https://github.com/settings/keys
            pbcopy < "${githubSshKey}.pub"
            echo "Press [Enter] to continue..."
            read -r
          fi
        fi

        echo "set up: TPM (Tmux Plugin Manager)"
        if test -d "${userHome}/.tmux/plugins/tpm"; then
          echo "skip: TPM already installed"
        else
          git clone https://github.com/tmux-plugins/tpm "${userHome}/.tmux/plugins/tpm"
          echo "TPM installed. Run 'prefix + I' inside tmux to install plugins."
        fi

        echo "set up: mise (runtime version manager)"
        if test -f "${userHome}/.local/bin/mise"; then
          echo "skip: mise already installed"
        else
          curl https://mise.run | sh
        fi

        echo "set up: Rust (via rustup)"
        if test -d "${userHome}/.cargo"; then
          echo "skip: rustup already installed"
        else
          curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
        fi

        echo "Set up .secrets.env containing machine or organisation specific secrets, e.g. Artifactory credentials, Cloudflare credentials or device identifiers."
        touch "$HOME/.secrets.env"

        # --- GUI steps (skipped over SSH) ---

        if is_ssh; then
          echo ""
          echo "Skipping GUI steps (running over SSH). Run this again locally for:"
          echo "  - Gmail login"
          echo "  - Google Meet PWA"
          echo "  - DaVinci Resolve install"
          echo "  - Apple Account login"
          exit 0
        fi

        echo "manual: login to gmail"
        open -a "${browser}" https://gmail.com

        echo "Save Google Meet as PWA"
        open -a "${browser}" https://meet.google.com
        echo "Press [Enter] to continue..."
        read -r

        echo "manual: install apps"
        open "https://www.blackmagicdesign.com/products/davinciresolve"
        read -r

        echo "login: macOS Apple Account"
        open "/System/Library/PreferencePanes/AppleIDPrefPane.prefPane"
        echo "Press [Enter] after logging in..."
        read -r
      '';
    };
in "${app}/bin/setup"