# dotfiles
alias cf='/usr/bin/git --git-dir=$HOME/.cfg --work-tree=$HOME'
setopt completealiases

# Help pages (zsh doesn't enable them by default). See https://superuser.com/questions/1563825/is-there-a-zsh-equivalent-to-the-bash-help-builtin
unalias run-help
autoload run-help
HELPDIR=/usr/share/zsh/"${ZSH_VERSION}"/help
alias help=run-help

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
# ZSH_THEME="agnoster"
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
plugins=(git zsh-autosuggestions asdf z)

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

# autoload -U +X bashcompinit && bashcompinit
# complete -o nospace -C /opt/homebrew/bin/terraform terraform

# rust
export PATH=$PATH:~/.cargo/bin

# Poetry
export PATH="$HOME/.poetry/bin:$PATH"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

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
export PNPM_HOME="/Users/zen/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# flutter
export PATH=/opt/flutter/bin:$PATH
# Flutter / pub
export PATH="$PATH":"$HOME/.pub-cache/bin"
# For working on the Flutter repo
export PATH="$PATH:/opt/depot_tools"
# For fastlane
export FLUTTER_ROOT=/opt/flutter
export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=xngh-swkt-bliw-bfbl

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#nvm, auto set by https://github.com/nvm-sh/nvm#install--update-script
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# CMake
export PATH="/Applications/CMake.app/Contents/bin:$PATH"

# Postgres
export PATH="/Library/PostgreSQL/15/bin:$PATH"
# export LIBRARY_PATH="/Library/PostgreSQL/15/lib:$LIBRARY_PATH"

# Neovim
export PATH="$PATH:/opt/nvim/bin"
alias vim=nvim
alias vi=vim
alias v=vi

# mysql
export PATH="$PATH:/usr/local/mysql/bin"

# Python PDM
export PATH="/Users/zen/.local/bin:$PATH"

# Google SDK
export PATH="/opt/google-cloud-sdk/bin:$PATH"

# Deno
export DENO_INSTALL="/Users/zen/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# Autocompletions
fpath=(~/.zsh $fpath)
autoload -Uz compinit
compinit -u

# fnm
export PATH="/Users/zen/Library/Application Support/fnm:$PATH"
if command -v fnm &> /dev/null
then
eval "`fnm env`"
fi

# Volta/node
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# gcloud
export PATH="$PATH:/opt/google-cloud-sdk/bin"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Secrets
source "$HOME/.secrets.env"
# WARNING: ADD SECRETS TO .secrets.env, not here.

# bun completions
[ -s "/Users/zen/.bun/_bun" ] && source "/Users/zen/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

gitgc() {
  git branch --merged | grep -v "\*" | xargs -n 1 git branch -d
}
