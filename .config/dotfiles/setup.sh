# First time machine setup script. See https://github.com/ben-xD/dotfiles-macos for more information.

if test -f "/$HOME/.ssh/github"; then
  echo "create: creating GitHub ssh key with no passphrase."
  ssh-keygen -f "$HOME/.ssh/github" -N ""
  echo "Add the key to GitHub: https://github.com/settings/keys"
else
  echo "skip: github ssh key already exists"
fi

echo "install: macOS developer dependencies (Xcode)"
xcode-select --install

if test ! $(which brew); then
else
  echo "skip: brew is already installed"
fi

echo "install: oh-my-zsh, as per https://ohmyz.sh/#install"
echo "More plugins available on https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "install: zsh plugins"
# as per https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/agkozak/zsh-z ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-z
git clone https://github.com/asdf-vm/asdf.git ~/.asdf

echo "install powerlevel10k, as per https://github.com/romkatv/powerlevel10k#installation"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

## nvim
echo "install: neovim, as per https://github.com/neovim/neovim/wiki/Installing-Neovim#macos--os-x"
brew install neovim
echo "setting up symlink for custom neovim configuration"
ln -s "$HOME/.config/dotfiles/nvim-custom/" "$HOME/.config/nvim/lua/custom"

echo "Install apps via brew. Find more casks on https://formulae.brew.sh/cask/"
brew install --cask rectangle
brew install --cask itsycal
brew install --cask alfred
brew install --cask visual-studio-code
brew install --cask cleanshot
brew install --cask firefox
brew install --cask docker
brew install --cask figma
brew install --cask obsidian
brew install --cask fork
brew install --cask google-chrome
brew install --cask qlmarkdown
brew install --cask yubico-yubikey-manager
brew install --cask iterm2
brew install --cask logi-options-plus
brew install --cask typora
brew install --cask trailer
brew install --cask slack
# Need a custom cask? see https://github.com/Homebrew/homebrew-cask/blob/c1bc489c27f061871660c902c89a250a621fb7aa/Casks/e/eagle.rb

echo "Manually install apps: Eagle.cool, "

# GPG set up
# prompt for smartcard to be added
GPG_PUBLIC_KEY_ID="0x5FC80BAF2B00A4F9 2023-10-06"
brew install gnupg pinentry-mac
# Create subkey from GPG key on yubikey/smartcard
echo "manual(GitHub): Delete existing GPG public key and add new public key, containing subkey used by this machine."

echo "Add licenses to apps: alfred, cleanshot, fork"
echo "Copy configuration of Alfred"

echo "Finally, set up .secrets.env containing machine or organisation specific secrets, e.g. Artifactory credentials, Cloudflare credentials or device identifiers."
