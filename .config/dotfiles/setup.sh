#!/bin/bash
# Set error immediately if any command errors (e), error if variables undefined (u), error on pipeline error (-o pipefail). Why? See https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425
set -euo pipefail

# First time machine setup script. See https://github.com/ben-xD/dotfiles-macos for more information.
echo "install: Xcode Command Line Tools. Why? It's commonly needed for development."
xcode-select --install || true

echo "install: brew. Why? It helps us install more apps and developer tools without manually downloading files."
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "skip: brew is already installed, updating instead."
  brew update
fi

echo "install: oh-my-zsh, as per https://ohmyz.sh/#install. Why? It makes using command line more comfortable."
echo "More plugins available on https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins"
# Prevent oh-my-zsh starting a new shell, which will block the script. See https://github.com/ohmyzsh/ohmyzsh/issues/4261
NO_INTERACTIVE=true sh -c "$(curl -fsSL https://raw.githubusercontent.com/subtlepseudonym/oh-my-zsh/feature/install-noninteractive/tools/install.sh)"

echo "install: zsh plugins. Why?: check the docs for each plugin."
# as per https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# TODO Consider zoxide?: https://github.com/ajeetdsouza/zoxide
git clone https://github.com/agkozak/zsh-z ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-z
git clone https://github.com/asdf-vm/asdf.git ~/.asdf

echo "install powerlevel10k, as per https://github.com/romkatv/powerlevel10k#installation. Why? It makes the command line tidy."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

## nvim
echo "install: neovim, as per https://github.com/neovim/neovim/wiki/Installing-Neovim#macos--os-x. Why? It avoids Microsoft (corporate, behemoth, buggy software) and Jetbrains IDEs (JDK, slow)"
brew install neovim
echo "setting up symlink for custom neovim configuration"
ln -s "$HOME/.config/dotfiles/nvim-custom/" "$HOME/.config/nvim/lua/custom"

echo "install: pyenv. Why? Manage python versions so you don't suffer with python setup and version management."
brew install pyenv
exec $SHELL # so we can use pyenv
pyenv install 3.11
pyenv global 3.11

## nvm
echo "install: nvm. Why? Manage node versions so you can have multiple versions easily."
brew install nvm

## More dev tools
brew install mas # https://github.com/mas-cli/mas
brew install htop
brew install legit
# brew install git-flow
brew install git-extras
brew install tree
brew install wget
brew install trash
brew install ollama

## TODO Consider more tools?
# brew install coreutils curl git openssl readline sqlite3 xz zlib tcl-tk # needed for asdf and asdf-python

# GPG set up
# prompt for smartcard to be added
GPG_PUBLIC_KEY_ID="0x5FC80BAF2B00A4F9 2023-10-06"
brew install gnupg pinentry-mac
# Create subkey from GPG key on yubikey/smartcard
echo "manual(GitHub): Delete existing GPG public key and add new public key, containing subkey used by this machine."
read -p "Press [Enter] to continue..."

echo "Add licenses to apps: alfred, cleanshot, fork"
read -p "Press [Enter] to continue..."

echo "Copy configuration of Alfred"
read -p "Press [Enter] to continue..."

echo "Login to browsers and browser extensions"
read -p "Press [Enter] to continue..."

echo "Save Google Meet as PWA"
open -a "google chrome" https://meet.google.com
read -p "Press [Enter] to continue..."

echo "Manually install apps:"
open "https://eagle.cool/"
open "https://www.blackmagicdesign.com/products/davinciresolve"
read -p "Press [Enter] to continue..."

echo "Set up .secrets.env containing machine or organisation specific secrets, e.g. Artifactory credentials, Cloudflare credentials or device identifiers."
touch "$HOME/.secrets.env"

echo "install: apps via brew. Find more casks on https://formulae.brew.sh/cask/"
# Need a custom cask? see https://github.com/Homebrew/homebrew-cask/blob/c1bc489c27f061871660c902c89a250a621fb7aa/Casks/e/eagle.rb
apps=(
  iterm2
  rectangle
  itsycal
  alfred
  visual-studio-code
  jetbrains-toolbox
  cleanshot
  firefox
  google-chrome
  microsoft-edge
  docker
  figma
  obsidian
  fork
  qlmarkdown
  qlstephen
  yubico-yubikey-manager
  logi-options-plus
  typora
  trailer
  slack
  bartender
  vlc
  monitorcontrol
)
# Install apps to /Applications
# Default is: /Users/$user/Applications
brew install --cask --appdir="/Applications" ${apps[@]}

extra_apps=(
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
)
# TODO make it optional
brew install --cask --appdir="/Applications" ${apps[@]}

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

brew cask alfred link

brew cask cleanup
brew cleanup

# Login with Apple Account
echo "login: macOS Apple Account"
open "/System/Library/PreferencePanes/AppleIDPrefPane.prefPane"
read -p "Press [Enter] after logging in..."

# Install Mac App Store apps
mas install 1352778147 # bitwarden
mas install 937984704 # amphetamine
mas install 899247664 # TestFlight
mas install 1140313689 # snippose

read -p "Do you want to download the file? (yes/no): " willDownloadJetbrainsFont
willDownloadJetbrainsFont=$(echo "$willDownloadJetbrainsFont" | tr '[:upper:]' '[:lower:]')
if [ "$answer" == "yes" ]; then
  wget "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip"
  unzip "JetbrainsMono.zip" -d JetbrainsMono
  open -b com.apple.FontBook JetBrainsMono/*.ttf
  trash "JetBrainsMono.zip" JetBrainsMono
  read -p "Unzi"
else
  echo "install(fonts): Download your preferred font and open the ttf files (with FontBook)"
  open "https://github.com/ryanoasis/nerd-fonts/releases"
fi

GITHUB_SSH_KEY="$HOME/.ssh/github"
if test -f $GITHUB_SSH_KEY; then
  echo "skip: github ssh key already exists"
else
  echo "create: creating GitHub ssh key with no passphrase."
  ssh-keygen -f $GITHUB_SSH_KEY -N ""
  echo "Add a new SSH key to GitHub. The public key is in your clipboard."
  open -a "firefox" https://github.com/settings/keys
  cat "${GITHUB_SSH_KEY}.pub" | pbcopy
  read -p "Press [Enter] to continue..."
fi

echo "Setting some macOS settings..."
read -p "Press [Enter] to continue..."

#"Disabling system-wide resume"
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

#"Disabling automatic termination of inactive apps"
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

#"Allow text selection in Quick Look"
defaults write com.apple.finder QLEnableTextSelection -bool TRUE

#"Disabling OS X Gate Keeper"
#"(You'll be able to install any app you want from here on, not just Mac App Store apps)"
sudo spctl --master-disable
sudo defaults write /var/db/SystemPolicy-prefs.plist enabled -string no
defaults write com.apple.LaunchServices LSQuarantine -bool false

#"Expanding the save panel by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

#"Automatically quit printer app once the print jobs complete"
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

#"Saving to disk (not to iCloud) by default"
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

#"Check for software updates daily, not just once per week"
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

#"Disable smart quotes and smart dashes as they are annoying when typing code"
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

#"Enabling full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

#"Disabling press-and-hold for keys in favor of a key repeat"
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

#"Setting trackpad & mouse speed to a reasonable number"
defaults write -g com.apple.trackpad.scaling 2
# System settings > Mouse > Mouse Sensitivity > Max
defaults write -g com.apple.mouse.scaling 3

#"Showing icons for hard drives, servers, and removable media on the desktop"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

#"Showing all filename extensions in Finder by default"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

#"Disabling the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

#"Use column view in all Finder windows by default"
defaults write com.apple.finder FXPreferredViewStyle Clmv

#"Avoiding the creation of .DS_Store files on network volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

#"Enabling snap-to-grid for icons on the desktop and in other icon views"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

#"Speeding up Mission Control animations and grouping windows by application"
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock "expose-group-by-app" -bool true

#"Setting email addresses to copy as 'foo@example.com' instead of 'Foo Bar <foo@example.com>' in Mail.app"
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

#"Preventing Time Machine from prompting to use new hard drives as backup volume"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

#"Enabling Safari's debug menu"
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
#"Enabling the Develop menu and the Web Inspector in Safari"
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true
#"Adding a context menu item for showing the Web Inspector in web views"
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# Set  dock to left
read -p "Configuring dock. Press [Enter] to continue..."
defaults write com.apple.dock orientation -string leftkillall
#"Setting Dock to auto-hide and removing the auto-hiding delay"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0
#"Setting the icon size of Dock items in pixels (large)
defaults write com.apple.dock tilesize -int 90

killall Dock
killall Finder
