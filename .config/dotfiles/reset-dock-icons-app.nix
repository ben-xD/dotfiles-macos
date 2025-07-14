{ nixpkgs }:
system: let
  pkgs = import nixpkgs { inherit system; };
  app = pkgs.writeShellApplication {
    name = "reset-dock-icons";
    text = ''
      echo "Resetting Dock icons..."
      defaults write com.apple.dock persistent-apps -array
      killall Dock
    '';
  };
in "${app}/bin/reset-dock-icons"