# dotfiles-macos

Reproducible set up for my macOS machines. Using a bare git repo (files are not inside the cloned folder), we set the working tree to be the home folder instead. Then we install tools using zsh, brew and macOS commands. Consider forking the repo and modifying the files to customise your setup.

## Usage

### Setting up a new machine

- Open Terminal.app
- Run `xcode-select --install`, and click "Install". Wait for it to finish.
- Run the following script:
```bash
echo "Clone the repo into ~/.cfg"
git clone --bare https://github.com/ben-xD/dotfiles-macos.git $HOME/.cfg
echo "Set temporary alias"
alias cf='/usr/bin/git --git-dir=$HOME/.cfg --work-tree=$HOME'
echo "Hide untracked files"
cf config --local status.showUntrackedFiles no
echo "Getting files"
cf checkout
```
- If you get an errors (like `files would be overwritten by checkout`), see https://www.atlassian.com/git/tutorials/dotfiles"
- "Run `.config/dotfiles/setup.sh` and follow its instructions. For more info, read the script.

### Making changes
- Make changes to any config
- Add the file to the git staging area: run `cf add $filename`
- Commit: run `cf commit -m "example commit message"`
- push to github: run `cf push`
- [on other machines] pull changes: `cf pull`

## Warnings

- Don't use [mackup](https://github.com/lra/mackup), it causes data loss. See https://github.com/lra/mackup/issues/1944 and https://github.com/lra/mackup/issues/1913.

## Project history

- Inspired by https://www.atlassian.com/git/tutorials/dotfiles
- Inspired by https://gist.githubusercontent.com/eknowles/71ed8b770cd66adb96d5fbe8241e01e8/raw/532392d60d4973421e29b040a2867c224eb5f0c8/mac-setup.md
