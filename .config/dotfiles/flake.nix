{
  description = "Ben Butterworth's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    
    # https://github.com/nix-community/home-manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    
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

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, homebrew-core, homebrew-cask, home-manager }:
  let
    username = "jiji";
    config = { pkgs, ... }: {
      # To disable nix-darwin management of nix, which determinate systems does instead
      nix.enable = false;

      users.users.${username}.home = "/Users/${username}";

      nix.extraOptions = ''
        extra-platforms = x86_64-darwin aarch64-darwin
      '';

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [
        # Editors & Shell
        vim
        neovim
        starship
        # System/Mac Utilities
        rectangle
        darwin.trash
        pinentry_mac
        gnupg
        bartender
        itsycal
        monitorcontrol
        betterdisplay
        stats
        mas
        # Browsers
        brave
        google-chrome
        firefox
        # Productivity
        raycast
        obsidian
        syncthing
        # Dev Tools
        vscode
        tree
        wget
        htop
        uv
        fnm
        git-extras
        k9s
        ollama
        wireshark
        # fonts
        jetbrains-mono
        # The tailscale package doesn't include the mac menu bar, so we use the cask instead
        # tailscale
        # Not always needed
        # obs-studio
        # net-news-wire
        # zotero
        # qbittorrent
        # blender
      ];

      # Enable Tailscale service
      services.tailscale.enable = true;

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
      # More in https://github.com/nix-darwin/nix-darwin/tree/master/modules/system/defaults
      system.defaults = {
          # Setting Dock to auto-hide and removing the auto-hiding delay
          dock.autohide = true;
          dock.autohide-delay = 0.0;
          dock.autohide-time-modifier = 0.0;
          # Setting the icon size of Dock items in pixels (large)
          dock.tilesize = 90;
          # Speeding up Mission Control animations and grouping windows by application
          dock.expose-animation-duration = 0.1;
          dock.expose-group-apps = true;
          # Grey out apps that have been hidden (Command + H)
          dock.showhidden = true;
          dock.mru-spaces = false;
          dock.orientation = "left";
          dock.show-recents = false;
          finder.AppleShowAllExtensions = true;
          finder.FXPreferredViewStyle = "clmv";
          finder.AppleShowAllFiles = true;
          loginwindow.LoginwindowText = "If found, please email ben@orth.uk, contact +44 7482 148484 or +447927067521";
          screencapture.location = "~/Desktop";

          # Expanding the save and print panels by default
          NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
          NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
          NSGlobalDomain.PMPrintingExpandedStateForPrint = true;
          NSGlobalDomain.PMPrintingExpandedStateForPrint2 = true;
          # Show path bar in the bottom of Finder windows"
          finder.ShowPathbar = true;
          # Disabling the warning when changing a file extension
          finder.
          FXEnableExtensionChangeWarning = false;

          # Disable smart quotes and smart dashes as they are annoying when typing code
          NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
          NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
          # Enable function keys to work as standard function keys by default
          NSGlobalDomain."com.apple.keyboard.fnState" = true;
          # Disable Gatekeeper. You'll be able to install any app you want from here on, not just Mac App Store apps
          LaunchServices.LSQuarantine = false;
          
          # Saving to disk (not to iCloud) by default
          NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;
          # Enabling full keyboard access for all controls (e.g. enable Tab in modal dialogs)
          NSGlobalDomain.AppleKeyboardUIMode = 3;
          
          # Setting mouse speed to a reasonable number
          ".GlobalPreferences"."com.apple.mouse.scaling" = 3.0;
          # Showing icons for hard drives, servers, and removable media on the desktop
          finder.ShowExternalHardDrivesOnDesktop = true;
      };

      system.activationScripts.postActivation.text = ''
        # Exit immediately if any command errors (e), error if variables undefined (u), error on pipeline error (-o pipefail). Why? See https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425

        set -euo pipefail
        # Install Rosetta 2 if not already installed (Apple Silicon only)
        if [[ "$(uname -m)" == "arm64" ]] && ! /usr/bin/pgrep oahd >/dev/null 2>&1; then
          echo "Installing Rosetta 2..."
          /usr/sbin/softwareupdate --install-rosetta --agree-to-license
        fi

        # Set Activity Monitor update period to 1 second
        defaults write com.apple.ActivityMonitor "UpdatePeriod" -int "1"
        # Automatically quit printer app once the print jobs complete
        defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true
        # Check for software updates daily, not just once per week
        defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
        # Avoiding the creation of .DS_Store files on network volumes
        defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
        # Setting trackpad speed to a reasonable number
        defaults write -g com.apple.trackpad.scaling 3
        # NSGlobalDomain.NSQuitAlwaysKeepsWindows = true; (TODO: open a PR on https://github.com/ben-xD/nix-darwin - true is already the default though)
        defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool true
        # Preventing Time Machine from prompting to use new hard drives as backup volume (TODO: Open a PR for this)
        defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

        #"Enabling snap-to-grid for icons on the desktop and in other icon views"
        /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" /Users/${username}/Library/Preferences/com.apple.finder.plist
        /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" /Users/${username}/Library/Preferences/com.apple.finder.plist
        /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" /Users/${username}/Library/Preferences/com.apple.finder.plist

        # Disable gatekeeper, allowing app from anywhere to run
        # sudo spctl --master-disable

        killall Finder || true
      '';

      # Reminder about brew: although it's convenient, brew has been painful when needing to specify a specific version of a package. This is important when using brew to install dependencies of C/C++ projects. I'll still use it for general purpose tools and apps, but not build dependencies.
      homebrew = {
        enable = true;
        brews = [];
      
        # Need a custom cask? see https://github.com/Homebrew/homebrew-cask/blob/c1bc489c27f061871660c902c89a250a621fb7aa/Casks/e/eagle.rb
        casks = [ 
          # Terminal & Dev Tools
          "ghostty" "alfred" "tailscale" "notunes" "surfshark" "trailer" "pdf-expert" "db-browser-for-sqlite" "jordanbaird-ice" "dbeaver-community" "postico" "cloudflare-warp" "calibre"
          # Productivity
          "cleanshot" "meetingbar" "typora" "figma" "ogdesign-eagle" "logi-options+"
          # Browsers
          "microsoft-edge"
          # Communication
          "chatgpt" "signal"
          # Utilities
          "fork" "podman-desktop" "proxyman" "vlc" "yubico-yubikey-manager"
          # Quick Look Plugins
          "qlmarkdown" "qlstephen"
        ];
        # Install Mac App Store apps. To get more ids, see https://github.com/mas-cli/mas?tab=readme-ov-file#-app-ids
        masApps = {
          "Xcode" = 497799835;
          "Windows app" = 1295203466;
          "Amphetamine" = 937984704;
          "Colorslurp" = 1505894090;
          # "Snippose" = 1140313689;
          # "TestFlight" = 899247664;
          # "Bitwarden" = 1352778147;
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

    homeManagerConfig = {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${username} = import ./home.nix;

      # Optionally, use home-manager.extraSpecialArgs to pass
      # arguments to home.nix
    };
    resetDockIconsApp = import ./reset-dock-icons-app.nix { inherit nixpkgs; };
    setupApp = import ./setup-app.nix { inherit nixpkgs username; };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#air25
    darwinConfigurations."air25" = nix-darwin.lib.darwinSystem {
      modules = [
        config
        nix-homebrew.darwinModules.nix-homebrew
        { nix-homebrew = nixHomebrewConfig; }
        home-manager.darwinModules.home-manager
        homeManagerConfig
      ];
    };

    apps.x86_64-darwin.reset-dock-icons = {
      type = "app";
      program = resetDockIconsApp "x86_64-darwin";
    };
    apps.aarch64-darwin.reset-dock-icons = {
      type = "app";
      program = resetDockIconsApp "aarch64-darwin";
    };
    apps.x86_64-darwin.setup = {
      type = "app";
      program = setupApp "x86_64-darwin";
    };
    apps.aarch64-darwin.setup = {
      type = "app";
      program = setupApp "aarch64-darwin";
    };
  };
}
