# dotfiles-macos

Reproducible set up for my macOS machines. Using a bare git repo (files are not inside the cloned folder), we set the working tree to be the home folder instead. Then we install tools using zsh, brew and macOS commands. Consider forking the repo and modifying the files to customise your setup.

## Usage

### Setting up a new machine

- Open Terminal.app and run
```bash
xcode-select --install
```
- Click "Install" and wait for it to finish
- Run
```bash
echo "Clone the repo into ~/.cfg"
git clone --bare https://github.com/ben-xD/dotfiles-macos.git $HOME/.cfg
cf() {
    /usr/bin/git --git-dir=$HOME/.cfg --work-tree=$HOME "$@"
}
echo "Hide untracked files"
cf config --local status.showUntrackedFiles no
echo "Getting files"
cf checkout
cf remote set-url origin git@github.com:ben-xD/dotfiles-macos.git
cf update-index --assume-unchanged .gitconfig
# Install rosetta
softwareupdate --install-rosetta --agree-to-license

# Install Nix with Determinate Systems. https://docs.determinate.systems/
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate
```
- If you get an errors (like `files would be overwritten by checkout`), see https://www.atlassian.com/git/tutorials/dotfiles
- Run
```bash
.config/dotfiles/setup.sh
```
- Optional: If you'd like to use GPG keys, configure machine to use a new subkey from your GPG key. See [Adding a machine subkey](#adding-a-machine-subkey).

### Making changes
- Make changes to any config
- Add the file to the git staging area: run `cf add $filename`
- Commit: run `cf commit -m "example commit message"`
- push to github: run `cf push`
- [on other machines] pull changes: `cf pull`
- Any other git commands? Use `cf` instead of git

## Limitations

- Unfortunately, this doesn’t currently automate all macOS settings or app configuration (and licenses/activation). Some people have used chezmoi, but my first attempt caused some issues.

## Project history

- Inspired by https://www.atlassian.com/git/tutorials/dotfiles
- Inspired by https://gist.githubusercontent.com/eknowles/71ed8b770cd66adb96d5fbe8241e01e8/raw/532392d60d4973421e29b040a2867c224eb5f0c8/mac-setup.md

## Set up GPG
I use GPG subkeys on my machines, with a GPG key on a Yubikey/smartcard.

### Set up GPG key

- Create PGP key using GPG: run `gpg --full-generate-key`
- Back up the private key
  - You could create a QR (or split across multiple QR codes) or store the private key digitally. For example, you couldencrypt the private key using GPG and upload it to a password manager, or keep on a USB stick.
  - #not-done create paper copy with QR code. See https://security.stackexchange.com/questions/51771/where-do-you-store-your-personal-private-gpg-key
  - I keep it digitally in my password manager. You could either add a passphrase to the private key, or use gpg symmetric encryption.
  - I use `gpg --symmetric $filename` which will generate an ecrypted file: `$filename.gpg`. It will ask for a password.
  - To decrypt, run `gpg $filename`.

### Add it to Github
- Open GitHub's [key page](https://github.com/settings/keys) and click **add new GPG key**
    - Name it following a meaningful format, e.g. , e.g. `ben.20231006`
- Reminder: Re-export public key and replace existing GPG key on Github, otherwise the subkey won't be recognized by Github.
    - Run `gpg --export --armor $public_key_id > gpg.$(whoami).$(date +%Y%m%d).pub`
    - Copy to clipboard: `cat gpg.$(whoami).$(date +%Y%m%d).pub | pbcopy`
    - Paste the output into a new GPG key. Name it the same as the file to be consistent.

### Configure git
- See your existing config: `git config --global --list`
- Configure to use this new key:
    - Run: `git config --global commit.gpgsign true`
    - Run: `git config --global user.signingkey $signing_key`, update it to use your public key. You can get the from `gpg --list-keys`
    - Run: `git config --global gpg.program "$(which gpg)"` so that other apps (e.g. GitHub app, and obisidian-git for Obisidian) can find gpg and won't throw error. See [Git Hub Desktop on Mac, error: cannot run gpg: No such file or directory](https://stackoverflow.com/a/37261769/7365866).
- Test:
    - Make some changes to a repo and create a git commit
    - Check commit includes GPG signature: `git log --show-signature`

### Configure other machines to trust the public key
- To fix the issue: Not certified with trusted signature
```bash
gpg: Signature made Fri  6 Oct 14:39:04 2023 BST
gpg:                using RSA key 6A4BE50A13CE50C14E3187955FC80BAF2B00A4F9
gpg: Good signature from "Ben Butterworth (https://orth.uk) <24711048+ben-xD@users.noreply.github.com>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: 6A4B E50A 13CE 50C1 4E31  8795 5FC8 0BAF 2B00 A4F9
```
- Download the public key onto the device (e.g. using Airdrop, Bitwarden secure note, file server)
- install `GnuPG` and `pinentry-mac`: run `brew install gnupg pinentry-mac`
- Import the public key into the machine: `gpg --import $file`
- List available keys to get the key id: `gpg --list-keys`
- Edit the key: run `gpg --edit-key $key_id`
    - enter `trust`, and select `5` (Ultimate trust - you created this key).

### Adding a machine subkey

- Create one subkey for each machine. This avoids needing to plug in your smartcard every time you want to make a commit. Get a subkey and use that instead so I don't need hardware plugged in.
- Plug in yubikey
- Let machine detect it, run `gpg --edit-card`
- Create subkey: run `gpg --edit-key $public_key_id`
    - You should see "secret key is available"
    - run `addkey`
    - Select `4`: `z(4) RSA (sign only)` and enter `4096`
    - Select an expiry date
        - It's better to extend the expiry date of existing subkeys instead of creating a new one. Why? After using a subkey on GitHub, you cannot delete it from the public key. Commits signed with that public subkey will be unverified if the new GPG public key doesn't include that subkey. This doesn't mean there is a tradeoff between the size of the GPG public key and how frequently you expire subkeys, because you can just extend the expiry date of the subkey.
    - Save it: run `save`
- and configure Git to use it: `git config --global user.signingkey $sub_key_id`
- Export the public key, run Run `gpg --export --armor $public_key_id > gpg.$(whoami).$(date +%Y%m%d).pub`
- Save this public key somewhere (e.g. in a password manager). You should use this public key the next time you add a subkey, because you can only upload 1 public key for all the subkeys to GitHub.
- Update GitHub with the new public key. GitHub needs to know about the newly added subkey. You can delete your previous one, since it should be a subset of the new key. Copy it to clipboard by running run `cat gpg.$(whoami).$(date +%Y%m%d).pub | pbcopy` and paste it into https://github.com/settings/gpg/new
