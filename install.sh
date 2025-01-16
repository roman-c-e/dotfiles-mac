#!/bin/zsh

# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew analytics off

## Formulae
echo "Installing Brew Formulae..."
### Essentials
brew install git
brew install --cask docker

### Languages
brew install php

### Terminal
brew install --cask kitty
brew install starship
brew install gitui
brew install neovim
brew install zellij
brew install lsd
brew install bat
brew install tree-sitter
brew install ripgrep
brew install imagemagick
brew install rar
brew install wget
brew install zoxide
brew install yazi
brew install poppler
brew install ffmpeg
brew install sevenzip
brew install jless

### Mac Enhancements
brew install mas # Mac App Store CLI
brew install --cask alt-tab
brew install marta
brew install alfred
brew install karabiner-elements
brew install hammerspoon --cask

#brew tap FelixKratz/formulae
#brew install sketchybar
#brew install --cask nikitabobko/tap/aerospace
brew install koekeishiya/formulae/yabai

### Productivity
brew install --cask 1password
brew install 1password-cli
brew install --cask postman
brew install --cask google-drive
brew install --cask moonlight
brew install --cask jdownloader

### Media
brew install --cask vlc
brew install --cask spotify
brew install --cask comictagger

### Social
brew install slack
brew install --cask discord
brew install telegram

### Fonts
brew install --cask font-jetbrains-mono
brew install --cask font-fira-code
brew install --cask font-meslo-lg-nerd-font
brew install --cask font-hack-nerd-font

# Mac App Store Apps
echo "Installing Mac App Store Apps..."
#Wireguard
mas install 1451685025
#Magnet
#mas install 441258766

# Mac Settings
defaults write com.apple.dock autohide -bool true
defaults write com.apple.Finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.dock workspaces-auto-swoosh -bool NO
#defaults write NSGlobalDomain _HIHideMenuBar -bool true
defaults write -g NSWindowShouldDragOnGesture -bool true
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
defaults write AppleWindowTabbingMode -string always

# Start Services
#brew services start sketchybar
yabai --start-service