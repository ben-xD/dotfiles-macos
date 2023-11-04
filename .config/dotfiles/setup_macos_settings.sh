echo "Setting macOS settings..."
echo "There are many settings that can't (easily) be configured automatically. This just does the bare minimum."

#"Disabling system-wide resume"
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool true

#"Disabling OS X Gate Keeper"
#"(You'll be able to install any app you want from here on, not just Mac App Store apps)"
#sudo spctl --master-disable
#sudo defaults write /var/db/SystemPolicy-prefs.plist enabled -string no
#defaults write com.apple.LaunchServices LSQuarantine -bool false

#"Expanding the save panel by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

#"Activity monitor updates every second"
defaults write com.apple.ActivityMonitor "UpdatePeriod" -int "1"

#"F1, F2, etc. behave as standard function keys"
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true

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

#"Setting trackpad & mouse speed to a reasonable number"
defaults write -g com.apple.trackpad.scaling 3
# System settings > Mouse > Mouse Sensitivity > Max
defaults write -g com.apple.mouse.scaling 3

#"Showing icons for hard drives, servers, and removable media on the desktop"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

#"Showing all filename extensions in Finder by default"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

#"Disabling the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

#"Use column view in all Finder windows by default"
defaults write com.apple.finder "FXPreferredViewStyle" -string "clmv"

#"Show path bar in the bottom of Finder windows"
defaults write com.apple.finder "ShowPathbar" -bool "true"

#"Avoiding the creation of .DS_Store files on network volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

#"Enabling snap-to-grid for icons on the desktop and in other icon views"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

#"Preventing Time Machine from prompting to use new hard drives as backup volume"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Set dock to left
echo "Configuring dock. Press [Enter] to continue..."
read
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

echo "Do you want to show all hidden files in Finder? [yes/no, default: no]: "
read showHiddenFilesFinder
showHiddenFilesFinder=${showHiddenFilesFinder:l}
if [[ "$showHiddenFilesFinder" == "yes" ]]; then
  echo "Showing hidden files in finder..."
  defaults write com.apple.finder AppleShowAllFiles true
fi


echo "Do you want to remove all existing dock icons? [yes/no, default: no]: "
read removeExistingDockIcons
removeExistingDockIcons=${removeExistingDockIcons:l}

killall Dock # kill dock because the next command doesn't work without it
sleep 2 # wait for dock to restart to avoid next `killall Dock` from error'ing.
if [[ "$removeExistingDockIcons" == "yes" ]]; then
  echo "Removing existing dock icons..."
  defaults write com.apple.dock persistent-apps -array
fi

killall Dock
killall Finder
