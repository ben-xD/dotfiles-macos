# dotfiles-macos

- Secrets go in `.secrets.env` which are `.gitignore`'d.

## Project history

- Inspired by https://www.atlassian.com/git/tutorials/dotfiles
- Inspired by https://gist.githubusercontent.com/eknowles/71ed8b770cd66adb96d5fbe8241e01e8/raw/532392d60d4973421e29b040a2867c224eb5f0c8/mac-setup.md

## TODOs

- consider [pass](https://www.passwordstore.org/)
- Try chezmoi https://www.chezmoi.io/

## Setting up a new machine

- Clone the repo: run `git clone --bare git@github.com/ben-xD/dotfiles-macos.git .cfg`
- Set temporary alias: run `alias config='/usr/bin/git --git-dir=$HOME/.cfg --work-tree=$HOME'`
- Hide untracked files: run `config config --local status.showUntrackedFiles no`
- Get files: run `config checkout`
  - If you get an errors (like `files would be overwritten by checkout`), see https://www.atlassian.com/git/tutorials/dotfiles
- Run `./setup.sh`

## Manual setup

### Install nerd fonts

- Download them from the GitHub. Install them using Font Book

### Install Google Meet PWA and add to dock

## Warnings

- Don't use [mackup](https://github.com/lra/mackup), it causes data loss. See https://github.com/lra/mackup/issues/1944 and https://github.com/lra/mackup/issues/1913.
