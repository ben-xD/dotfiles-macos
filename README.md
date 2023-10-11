# dotfiles-macos

- Secrets go in `.secrets.env` which are `.gitignore`'d.

## Project history

- Inspired by https://www.atlassian.com/git/tutorials/dotfiles

## TODOs

- Move more nvim config to this repo
- Automate machine setup
  - app install
  - zsh install

- Try chezmoi https://www.chezmoi.io/

## Setting up a new machine

- Clone the repo: run `git clone --bare git@github.com/ben-xD/dotfiles-macos.git .cfg`
- Set temporary alias: run `alias config='/usr/bin/git --git-dir=$HOME/.cfg --work-tree=$HOME'`
- Hide untracked files: run `config config --local status.showUntrackedFiles no`
- Get files: run `config checkout`
  - If you get an errors (like `files would be overwritten by checkout`), see https://www.atlassian.com/git/tutorials/dotfiles

## Manual setup

### Install nerd fonts

- Download them from the GitHub. Install them using Font Book
