#!/bin/zsh
# First time machine setup script. See https://github.com/ben-xD/dotfiles-macos for more information.

# Exit immediately if any command errors (e), error if variables undefined (u), error on pipeline error (-o pipefail). Why? See https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425
set -euo pipefail

# Reminder about brew: although it's convenient, brew has been painful when needing to specify a specific version of a package. This is important when using brew to install dependencies of C/C++ projects. I'll still use it for general purpose tools and apps, but not build dependencies.

SCRIPT_PATH="${0:A:h}"
source "$SCRIPT_PATH/setup_macos_settings.sh"

echo "install: brew. Why? It helps us install more apps and developer tools without manually downloading files."
if which brew &>/dev/null; then
  echo "skip: brew is already installed, updating instead."
  brew update
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Primary browser install
brew install google-chrome --cask
# To avoid "Unable to find application named 'Google Chrome'" error immediately after installing
sleep 5
open -a "Google Chrome" https://gmail.com

## More dev tools
brew install k9s
brew install htop
brew install legit
brew install git-extras
brew install wget
brew install gnupg pinentry-mac
brew install trash tree
brew install ollama
brew install mas # https://github.com/mas-cli/mas

# Python version manager and package manager, https://docs.astral.sh/uv/getting-started/installation/
curl -LsSf https://astral.sh/uv/install.sh | sh

# Node version manager, fnm https://github.com/Schniz/fnm
curl -fsSL https://fnm.vercel.app/install | bash

## nvim
echo "install: neovim, as per https://github.com/neovim/neovim/wiki/Installing-Neovim#macos--os-x."
brew install neovim

echo "setting up symlink for custom neovim configuration"
if [[ ! -d "$HOME/.config/nvim" ]]; then
  git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
  ln -s "$HOME/.config/dotfiles/nvim-custom/" "$HOME/.config/nvim/lua/custom"
  echo "On the next screen, wait for plugins to finish installing in nvim. Press [Enter] to continue..."
  nvim
fi

source $HOME/.zshrc || true

# Fonts
echo "Do you want to download and install the Jetbrains font? (yes/no): "
read willDownloadJetbrainsFont
willDownloadJetbrainsFont=$(echo "$willDownloadJetbrainsFont" | tr '[:upper:]' '[:lower:]')
if [[ "$willDownloadJetbrainsFont" == "yes" ]]; then
  wget "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip"
  unzip "JetbrainsMono.zip" -d JetbrainsMono
  open -b com.apple.FontBook JetBrainsMono/*.ttf
  echo "manual: manually install in FontBook. Press [Enter] after that's done..."
  read
  trash "JetBrainsMono.zip" JetBrainsMono
else
  echo "install(fonts): Download your preferred font and open the ttf files (with FontBook)"
  open "https://github.com/ryanoasis/nerd-fonts/releases"
fi

echo "set up: GitHub SSH key"
GITHUB_SSH_KEY="$HOME/.ssh/github"
if test -f $GITHUB_SSH_KEY; then
  echo "skip: github ssh key already exists"
else
  echo "create: creating GitHub ssh key with no passphrase."
  ssh-keygen -f $GITHUB_SSH_KEY -N ""
  echo "Add a new SSH key to GitHub. The public key is in your clipboard."
  open -a "Google Chrome" https://github.com/settings/keys
  cat "${GITHUB_SSH_KEY}.pub" | pbcopy
  echo "Press [Enter] to continue..."
  read
fi

echo "Set up sudo with touch id"
sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local
umask 000
sudo chmod +r /etc/pam.d/sudo_local
echo "Uncomment the line with pam_tid.so in the next file to set up sudo with touch id, and press :w!. Press [Enter] to continue..."
read
sudo vim /etc/pam.d/sudo_local

echo "Set up .secrets.env containing machine or organisation specific secrets, e.g. Artifactory credentials, Cloudflare credentials or device identifiers."
touch "$HOME/.secrets.env"

brew install iterm2 rectangle --cask
echo "install: iterm2 themes"
wget https://github.com/mbadolato/iTerm2-Color-Schemes/tarball/master -O themes.tar.gz
tar -xvf themes.tar.gz
pushd mbadolato-iTerm2-Color-Schemes*
tools/import-scheme.sh  schemes/*
popd
trash themes.tar.gz mbadolato-iTerm2-Color-Schemes*

echo "install: oh-my-zsh, as per https://ohmyz.sh/#install. Why? It makes using command line more comfortable."
echo "More plugins available on https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins"
if test -d "$HOME/.oh-my-zsh"; then
  echo "skip: oh-my-zsh is already installed"
else
  # Prevent oh-my-zsh starting a new shell, which will block the script. See https://github.com/ohmyzsh/ohmyzsh/issues/4261
  NO_INTERACTIVE=true sh -c "$(curl -fsSL https://raw.githubusercontent.com/subtlepseudonym/oh-my-zsh/feature/install-noninteractive/tools/install.sh)"
  mv $HOME/.zshrc.pre-oh-my-zsh $HOME/.zshrc

  echo "install: zsh plugins. Why?: check the docs for each plugin."
  # as per https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  # TODO Consider zoxide?: https://github.com/ajeetdsouza/zoxide
  git clone https://github.com/agkozak/zsh-z ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-z
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf
fi

echo "install: powerlevel10k, as per https://github.com/romkatv/powerlevel10k#installation. Why? It makes the command line tidy."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

echo "install: rosetta 2 for running x86_64 apps on Apple Silicon. Accept the prompt."
# Needed by yubico-yubikey-manager
sudo softwareupdate --install-rosetta

echo "install: apps via brew. Find more casks on https://formulae.brew.sh/cask/"
echo "Do you want to install extra apps? Some apps will still be installed. (yes/no): "
read toInstallExtraApps
toInstallExtraApps=$(echo "$toInstallExtraApps" | tr '[:upper:]' '[:lower:]')
# Need a custom cask? see https://github.com/Homebrew/homebrew-cask/blob/c1bc489c27f061871660c902c89a250a621fb7aa/Casks/e/eagle.rb
apps=(
  alfred
  stats
  obsidian
  cleanshot
  fork
  visual-studio-code
  podman-desktop
  meetingbar
  firefox
  microsoft-edge
  figma
  qlmarkdown
  qlstephen
  yubico-yubikey-manager
  typora
  vlc
  proxyman
  chatgpt
  signal
  whatsapp
)
# Install apps to /Applications
# Default is: /Users/$user/Applications
# brew install --cask --appdir="/Applications" ${apps[@]} || true
echo "Installing apps"
for app in "${apps[@]}"; do
    brew install --cask --appdir="/Applications" "$app" || echo "Failed to install $app"
done

echo "manual: login to gmail"
open -a "google chrome" https://gmail.com

echo "Save Google Meet as PWA"
open -a "google chrome" https://meet.google.com
echo "Press [Enter] to continue..."
read

extra_apps=(
  surfshark
  tailscale
  wireshark
  cloudflare-warp
  discord
  slack
  monitorcontrol
  jordanbaird-ice
  trailer
  itsycal
  obs
  netnewswire
  bartender
  zotero
  pdf-expert
  qbittorrent
  calibre
  blender
  betterdisplay
  db-browser-for-sqlite
  dbeaver-community
  postico
  notunes
)

if [[ "$toInstallExtraApps" == "yes" ]]; then
  echo "Installing extra apps..."
  for app in "${extra_apps[@]}"; do
      brew install --cask --appdir="/Applications" "$app" || echo "Failed to install $app"
  done
else
  echo "Skipping..."
fi

echo "manual: install apps"
open "https://www.logitech.com/en-gb/software/logi-options-plus.html"
open "https://eagle.cool/"
open "https://www.blackmagicdesign.com/products/davinciresolve"
open "https://syncthing.net/downloads/"
echo "Press [Enter] to continue..."
read

# Login with Apple Account
echo "login: macOS Apple Account"
open "/System/Library/PreferencePanes/AppleIDPrefPane.prefPane"
echo "Press [Enter] after logging in..."
read

# Install Mac App Store apps. To get more ids, see https://github.com/mas-cli/mas?tab=readme-ov-file#-app-ids
# quick command: run `mas list` to see what you already have
echo "install: macOS apps from the App Store. Bitwarden, amphetamine, testflight, snippose and colorslurp"
mas install 1352778147 # bitwarden
mas install 1295203466 # windows app (previously remote desktop)
mas install 937984704 # amphetamine
mas install 899247664 # TestFlight
mas install 1140313689 # snippose
mas install 1287239339 # ColorSlurp

brew cleanup

# Finally, swap git repo to use SSH instead of HTTPS
cf remote set-url origin git@github.com:ben-xD/dotfiles-macos.git
cf push --set-upstream origin main
