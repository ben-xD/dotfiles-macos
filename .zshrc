# dotfiles
alias cf='/usr/bin/git --git-dir=$HOME/.cfg --work-tree=$HOME'
setopt completealiases

# Help pages (zsh doesn't enable them by default). See https://superuser.com/questions/1563825/is-there-a-zsh-equivalent-to-the-bash-help-builtin
# This errors with `/Users/safe/.zshrc:unalias:8: no such hash table element: run-help` in VSCode
if [[ "$TERM_PROGRAM" != "vscode" ]]; then
  unalias run-help
  autoload run-help
  HELPDIR=/usr/share/zsh/"${ZSH_VERSION}"/help
  alias help=run-help
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Disable homebrew analytics, as per https://docs.brew.sh/Analytics#opting-out
export HOMEBREW_NO_ANALYTICS=1

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# I removed asdf because i didn't use it, and it got in the way of install cocoapods (`sudo gem install cocoapods`).
plugins=(git zsh-autosuggestions z)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# rbenv
if command -v rbenv &> /dev/null
then eval "$(rbenv init - zsh)"
fi

export PATH="$HOME/.jenv/bin:$PATH"
if command -v jenv &> /dev/null
then eval "$(jenv init -)"
fi

# Mongo
export PATH=$PATH:/opt/mongo/bin

# ADB for android studio old emulator API level 21
export PATH=/Users/zen/Library/Android/sdk/platform-tools:$PATH
export GOOGLE_JAVA_FORMAT_PATH=/opt/google-java-format-1.13.0-all-deps.jar

# umask
umask 077

# rust
export PATH=$PATH:~/.cargo/bin

# GO
export GOPATH="$HOME/go"
PATH="$GOPATH/bin:$PATH"

# Override macOS's OpenSSL
export PATH="/opt/homebrew/opt/openssl@3/bin:$PATH"

# erlang
export MANPATH=$MANPATH:/opt/homebrew/opt/erlang/lib/erlang/man

# tailscale
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

# OpenBB
alias bb="bash /Applications/OpenBB\ Terminal/OpenBB\ Terminal"

# pnpm
export PNPM_HOME="/Users/safe/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# fnm
FNM_PATH="/Users/safe/Library/Application Support/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="/Users/safe/Library/Application Support/fnm:$PATH"
  eval "`fnm env`"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

. "$HOME/.local/bin/env"

# adb, installed with Android Studio
export PATH="$PATH:/Users/safe/Library/Android/sdk/platform-tools"

# CMake
export PATH="$PATH:/Applications/CMake.app/Contents/bin"
# bun completions
[ -s "/Users/safe/.bun/_bun" ] && source "/Users/safe/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Gstreamer
export PATH="/Library/Frameworks/GStreamer.framework/Versions/Current/bin:$PATH"

# Flutter
export PATH="$HOME/repos/flutter/bin:$PATH"

# Android Studio
export PATH="/Applications/Android Studio.app/Contents/MacOS:$PATH"
# eval "$(~/.local/bin/mise activate zsh)"

# Added by Windsurf
export PATH="/Users/safe/.codeium/windsurf/bin:$PATH"

# Fly (I prefer to install via script, not brew: `curl -L https://fly.io/install.sh | sh`)
export FLYCTL_INSTALL="/Users/safe/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"


# VSCode, to read from terminal. See https://github.com/cline/cline/wiki/Troubleshooting-%E2%80%90-Shell-Integration-Unavailable#still-having-trouble and https://code.visualstudio.com/docs/terminal/shell-integration#_manual-installation
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"
