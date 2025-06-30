{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    
    # https://github.com/zhaofengli/nix-homebrew
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:Homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:Homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, homebrew-core, homebrew-cask }:
  let
    username = "jiji";
    configuration = { pkgs, ... }: {
      # To disable nix-darwin management of nix, which determinate systems does instead
      nix.enable = false;

      # Needed to manually run ` softwareupdate --install-rosetta --agree-to-license` too
      nix.extraOptions = ''
        extra-platforms = x86_64-darwin aarch64-darwin
      '';

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.vim
          pkgs.rectangle
          pkgs.starship
          pkgs.gnupg
          pkgs.pinentry_mac
          pkgs.raycast
          pkgs.brave
          pkgs.obsidian
          pkgs.mas
        ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      # Sudo touch id
      security.pam.services.sudo_local.touchIdAuth = true;

      # Enable GPG agent
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };

      system.primaryUser = username;
      system.defaults = {
          dock.autohide = false;
          dock.mru-spaces = false;
          dock.orientation = "left";
          dock.show-recents = false;
          finder.AppleShowAllExtensions = true;
          finder.FXPreferredViewStyle = "clmv";
          loginwindow.LoginwindowText = "If found, please email ben@orth.uk or contact +44 7482 148484";
          screencapture.location = "~/Desktop/screenshots";
      };

      homebrew = {
        enable = true;
        brews = [];
        casks = [ "ghostty" "alfred" ];
        masApps = {
          "Xcode" = 497799835;
        };
      };
    };

    # Refactored nix-homebrew configuration for clarity and reuse
    nixHomebrewConfig = {
      # Enable Homebrew installation under the default prefix
      enable = true;

      # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
      enableRosetta = true;

      # User owning the Homebrew prefix
      user = username;

      # Declarative tap management: specify which taps to use
      taps = {
        "homebrew/homebrew-core" = homebrew-core;
        "homebrew/homebrew-cask" = homebrew-cask;
      };

      # Enable fully-declarative tap management (disables 'brew tap' imperatively)
      mutableTaps = false;
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#air25
    darwinConfigurations."air25" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        { nix-homebrew = nixHomebrewConfig; }
      ];
    };
  };
}
