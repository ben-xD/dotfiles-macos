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
        echo "set up: GitHub SSH key"
        if test -f "${githubSshKey}"; then
          echo "skip: github ssh key already exists"
        else
          echo "create: creating GitHub ssh key with no passphrase."
          ssh-keygen -f "${githubSshKey}" -N ""
          echo "Add a new SSH key to GitHub. The public key is in your clipboard."
          open -a "${browser}" https://github.com/settings/keys
          pbcopy < "${githubSshKey}.pub"
          echo "Press [Enter] to continue..."
          read -r
        fi

        echo "set up: TPM (Tmux Plugin Manager)"
        if test -d "${userHome}/.tmux/plugins/tpm"; then
          echo "skip: TPM already installed"
        else
          git clone https://github.com/tmux-plugins/tpm "${userHome}/.tmux/plugins/tpm"
          echo "TPM installed. Run 'prefix + I' inside tmux to install plugins."
        fi

        echo "Set up .secrets.env containing machine or organisation specific secrets, e.g. Artifactory credentials, Cloudflare credentials or device identifiers."
        touch "$HOME/.secrets.env"

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