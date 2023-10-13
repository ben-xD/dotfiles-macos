#!/bin/bash
# First time machine setup script. See https://github.com/ben-xD/dotfiles-macos for more information.

# Exit immediately if any command errors (e), error if variables undefined (u), error on pipeline error (-o pipefail). Why? See https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425
set -euo pipefail

echo "Setting macOS settings..."

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

#"Setting email addresses to copy as 'foo@example.com' instead of 'Foo Bar <foo@example.com>' in Mail.app"
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

#"Preventing Time Machine from prompting to use new hard drives as backup volume"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Set dock to left
read -p "Configuring dock. Press [Enter] to continue..."
defaults write com.apple.dock orientation -string left
#"Setting Dock to auto-hide and removing the auto-hiding delay"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0
#"Setting the icon size of Dock items in pixels (large)
defaults write com.apple.dock tilesize -int 90
#"Speeding up Mission Control animations and grouping windows by application"
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock "expose-group-by-app" -bool true
# Grey out apps that have been hidden (Command + H)
defaults write com.apple.dock showhidden -bool TRUE; killall Dock
defaults write com.apple.dock show-recents -bool false

read -p "Do you want to remove all existing dock icons?" removeExistingDockIcons
removeExistingDockIcons =$(echo "$removeExistingDockIcons" | tr '[:upper:]' '[:lower:]')
if [ "removeExistingDockIcons" == "yes" ]; then
  defaults write com.apple.dock persistent-apps -array
fi

killall Dock
killall Finder

echo "install: brew. Why? It helps us install more apps and developer tools without manually downloading files."
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "skip: brew is already installed, updating instead."
  brew update
fi

read -p "Do you want to download and install the Jetbrains font? (yes/no): " willDownloadJetbrainsFont
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

echo "install: apps via brew. Find more casks on https://formulae.brew.sh/cask/"
read -p "Do you want to install optional apps? (yes/no): " toInstallExtraApps
toInstallExtraApps=$(echo "$toInstallExtraApps" | tr '[:upper:]' '[:lower:]')
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
# brew install --cask --appdir="/Applications" ${apps[@]} || true
for app in "${apps[@]}"; do
    brew install --cask --appdir="/Applications" "$app" || echo "Failed to install $app"
done

echo "manual: feel free to open browsers to login "
open -a "firefox" https://gmail.com
open -a "google chrome" https://gmail.com

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

for app in "${extra_apps[@]}"; do
    brew install --cask --appdir="/Applications" "$app" || echo "Failed to install $app"
done

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

read -p "Press [Enter] to continue..."

## nvim
echo "install: neovim, as per https://github.com/neovim/neovim/wiki/Installing-Neovim#macos--os-x. Why? It avoids Microsoft (corporate, behemoth, buggy software) and Jetbrains IDEs (JDK, slow)"
brew install neovim
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 && nvim
exec $SHELL
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

## TODO More tools needed:
# brew install coreutils curl git openssl readline sqlite3 xz zlib tcl-tk # needed for asdf and asdf-python

echo "Setting up GPG key. Why? It's needed for signing commits or encrypting files."
GPG_PUBLIC_KEY_ID="0x5FC80BAF2B00A4F9 2023-10-06"
brew install gnupg pinentry-mac
# TODO
echo "manual: create subkey from GPG key on yubikey/smartcard"
read -p "Insert smartcard/yubikey. Press [Enter] to continue..."

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

# Login with Apple Account
echo "login: macOS Apple Account"
open "/System/Library/PreferencePanes/AppleIDPrefPane.prefPane"
read -p "Press [Enter] after logging in..."

# Install Mac App Store apps
mas install 1352778147 # bitwarden
mas install 937984704 # amphetamine
mas install 899247664 # TestFlight
mas install 1140313689 # snippose

echo "install powerlevel10k, as per https://github.com/romkatv/powerlevel10k#installation. Why? It makes the command line tidy."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

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

# Set up sudo with touch id
sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local
umask 000
chmod +r /etc/pam.d/sudo_local
read -p "Uncomment the line in the next file to set up sudo with touch id. Press [Enter] to continue..."
vim /etc/pam.d/sudo_local
