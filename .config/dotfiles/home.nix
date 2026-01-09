{
  config,
  pkgs,
  username,
  nix4nvchad,
  ...
}:

let
  pnpmHome = "$HOME/.pnpm";
in
{
  imports = [
    nix4nvchad.homeManagerModule
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = username;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Enable direnv for automatic environment loading
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # Zsh configuration with Oh My Zsh
  programs.zsh = {
    enable = true;
    sessionVariables = {
      HOMEBREW_NO_ANALYTICS = "1";
      EDITOR = "nvim";
      BUN_INSTALL="$HOME/.bun";
      # https://bitwarden.com/help/ssh-agent
      # Confirm the file is available. Either in
      # - $HOME/.bitwarden-ssh-agent.sock (official dmg installer)
      # - $HOME/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock
      SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock";
      # ADB for android studio old emulator API level 21
      # We add The pnpm home directory to the PATH so that `pnpm install -g $package` doesn't error
      PATH = "$BUN_INSTALL/bin:/Users/${username}/repos/flutter/bin:/Users/${username}/Library/Android/sdk/platform-tools:/Users/safe/Library/Android/sdk/platform-tools:/Library/Frameworks/GStreamer.framework/Versions/Current/bin:${pnpmHome}:$PATH:/Users/safe/.opencode/bin";
      GOOGLE_JAVA_FORMAT_PATH = "/opt/google-java-format-1.13.0-all-deps.jar";
      # We set the PNPM_HOME to ensure pnpm can install global packages
      PNPM_HOME = pnpmHome;
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "z" ];
      theme = "robbyrussell"; # You can change this to any theme you prefer
    };

    # Additional zsh configuration
    shellAliases = {
      ll = "ls -la";
      la = "ls -la";
      l = "ls -l";
      ".." = "cd ..";
      "..." = "cd ../..";
    };

    # Custom zsh options
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };

    # Enable syntax highlighting and auto-suggestions
    autosuggestion.enable = true;
    enableCompletion = true;
    initContent = ''
      # umask
      umask 077

      # dotfiles
      alias cf='/usr/bin/git --git-dir=$HOME/.cfg --work-tree=$HOME'
      setopt completealiases

      # VSCode, to read from terminal. See https://github.com/cline/cline/wiki/Troubleshooting-%E2%80%90-Shell-Integration-Unavailable#still-having-trouble and https://code.visualstudio.com/docs/terminal/shell-integration#_manual-installation
      [[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

      # Help pages (zsh doesn't enable them by default). See https://superuser.com/questions/1563825/is-there-a-zsh-equivalent-to-the-bash-help-builtin
      if [[ "$TERM_PROGRAM" != "vscode" ]]; then
        unalias run-help 2>/dev/null || true
        autoload run-help
        HELPDIR=/usr/share/zsh/"''${ZSH_VERSION}"/help
        alias help=run-help
      fi

      # fnm
      eval "$(fnm env --use-on-cd)"

      # Rust up (manually installed from https://rustup.rs/)
      . "$HOME/.cargo/env"

      # # Don't enter tmux if already inside one.
      # if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
      #   tmux attach -t main || tmux new -s main
      # fi

      # This is ended up being annoying, so I disabled it.
      # https://github.com/jesseduffield/lazygit
      # lg()
      # {
      #     export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir
#
      #     lazygit "$@"
#
      #     if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
      #             cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
      #             rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
      #     fi
      # }

      alias lg="lazygit"

      # lazygit supports bare repos
      alias cflg="lazygit --git-dir=$HOME/.cfg --work-tree=$HOME"

      # Use nvim instead of vim. Use \vim to use old vim.
      alias vim="nvim"
      alias vi="nvim"

      alias cl="claude"

      # for fzf
      source <(fzf --zsh)
    '';

    # Additional plugins that work well with the setup
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.0";
          sha256 = "1g3pij5qn2j7v7jjac2a63lxd97mcsgw6xq6k5p7835q9fjiid98";
        };
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.7.1";
          sha256 = "03r6hpb5fy4yaakqm3lbf4xcvd408r44jgpv4lnzl9asp4sb9qc0";
        };
      }
      {
        name = "zoxide";
        src = pkgs.fetchFromGitHub {
          owner = "ajeetdsouza";
          repo = "zoxide";
          rev = "v0.9.8";
          sha256 = "sha256-8hXoC3vyR08hN8MMojnAO7yIskg4FsEm28GtFfh5liI=";
        };
      }
    ];
  };

  fonts.fontconfig.enable = true;

  programs.nvchad = {
    enable = true;
    extraPackages = with pkgs; [
      nodePackages.bash-language-server
      # docker-compose-language-service
      # dockerfile-language-server-nodejs
      emmet-language-server
      nixd
      (python3.withPackages (
        ps: with ps; [
          python-lsp-server
          flake8
        ]
      ))
    ];
    hm-activation = true;
    backup = true;
  };

  home.packages = with pkgs; [
    jetbrains-mono
    pnpm
    zoxide
  ];
}
