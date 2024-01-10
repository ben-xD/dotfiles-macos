#!/bin/zsh
# First time machine setup script. See https://github.com/ben-xD/dotfiles-macos for more information.

# Exit immediately if any command errors (e), error if variables undefined (u), error on pipeline error (-o pipefail). Why? See https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425
set -euo pipefail

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
brew install firefox --cask
open -a Firefox https://gmail.com

## More dev tools
brew install mas # https://github.com/mas-cli/mas
brew install k9s
brew install htop
brew install legit
brew install derailed/k9s/k9s
# brew install git-flow
brew install git-extras
brew install wget trash tree
brew install gnupg pinentry-mac
brew install ollama
brew install pyenv

# nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

## nvim
echo "install: neovim, as per https://github.com/neovim/neovim/wiki/Installing-Neovim#macos--os-x. Why? It avoids Microsoft (corporate, behemoth, buggy software) and Jetbrains IDEs (JDK, slow)"
brew install neovim

echo "setting up symlink for custom neovim configuration"
if [[ ! -d "$HOME/.config/nvim" ]]; then
  git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
  ln -s "$HOME/.config/dotfiles/nvim-custom/" "$HOME/.config/nvim/lua/custom"
  echo "On the next screen, wait for plugins to finish installing in nvim. Press [Enter] to continue..."
  nvim
fi

source $HOME/.zshrc || true
PYTHON_VERSION=3.11
pyenv install $PYTHON_VERSION || true
pyenv global $PYTHON_VERSION || true

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
  open -a "firefox" https://github.com/settings/keys
  cat "${GITHUB_SSH_KEY}.pub" | pbcopy
  echo "Press [Enter] to continue..."
  read
fi

echo "Set up sudo with touch id"
sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local
umask 000
sudo chmod +r /etc/pam.d/sudo_local
echo "Uncomment the line in the next file to set up sudo with touch id. Press [Enter] to continue..."
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

echo "install: apps via brew. Find more casks on https://formulae.brew.sh/cask/"
echo "Do you want to install extra apps? Some apps will still be installed. (yes/no): "
read toInstallExtraApps
toInstallExtraApps=$(echo "$toInstallExtraApps" | tr '[:upper:]' '[:lower:]')
# Need a custom cask? see https://github.com/Homebrew/homebrew-cask/blob/c1bc489c27f061871660c902c89a250a621fb7aa/Casks/e/eagle.rb
apps=(
  alfred
  obsidian
  cleanshot
  fork
  visual-studio-code
  docker
  meetingbar
  jetbrains-toolbox
  google-chrome
  microsoft-edge
  figma
  qlmarkdown
  qlstephen
  yubico-yubikey-manager
  typora
  slack
  bartender
  vlc
  monitorcontrol
  proxyman
  insomnia
)
# Install apps to /Applications
# Default is: /Users/$user/Applications
# brew install --cask --appdir="/Applications" ${apps[@]} || true
echo "Installing apps"
for app in "${apps[@]}"; do
    brew install --cask --appdir="/Applications" "$app" || echo "Failed to install $app"
done

echo "manual: feel free to open browsers to login "
open -a "firefox" https://gmail.com
open -a "google chrome" https://gmail.com

extra_apps=(
  trailer
  itsycal
  obs
  discord
  netnewswire
  little-snitch
  istats-menus
  wireshark
  bartender
  zotero
  pdf-expert
  qbittorrent
  calibre
  blender
  postico
  db-browser-for-sqlite
  dbeaver-community
  cloudflare-warp
  betterdisplay
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
echo "Press [Enter] to continue..."
read

# Login with Apple Account
echo "login: macOS Apple Account"
open "/System/Library/PreferencePanes/AppleIDPrefPane.prefPane"
echo "Press [Enter] after logging in..."
read

# Install Mac App Store apps
echo "install: macOS apps from the App Store. Bitwarden, amphetamine,"
mas install 1352778147 # bitwarden
mas install 937984704 # amphetamine
mas install 899247664 # TestFlight
mas install 1140313689 # snippose
mas install 1287239339 # ColorSlurp

# More apps to consider:
  # openbb terminal
  # raycast
  # bettertouchtool
  # cleanmymac
  # cloud
  # colloquy
  # cornerstone
  # diffmerge
  # harvest
  # hipchat
  # licecap
  # mou
  # razer-synapse
  # sublime-text2
  # textexpander
  # transmission
  # sequel-pro
  # chromecast
  # suspicious-package
  # AI apps:
  # DiffusionBee
  # Draw Things
  # GodMode

brew cleanup

echo "Setting up GPG key. Why? It's needed for signing commits or encrypting files."
echo "Press [Enter] to continue..."
read

echo "Add licenses to apps: alfred, cleanshot, fork"
echo "Press [Enter] to continue..."
read

echo "Copy configuration of Alfred"
echo "Press [Enter] to continue..."
read

echo "Login to browsers and browser extensions"
echo "Press [Enter] to continue..."
read

echo "Save Google Meet as PWA"
open -a "google chrome" https://meet.google.com
echo "Press [Enter] to continue..."
read

# Finally, use SSH instead of HTTPs
cf remote set-url origin git@github.com:ben-xD/dotfiles-macos.git
cf push --set-upstream origin main
