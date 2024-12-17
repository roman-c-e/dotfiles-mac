#!/bin/zsh

# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew analytics off

## Formulae
echo "Installing Brew Formulae..."
### Essentials
brew install git

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

### Mac Enhancements
brew install mas # Mac App Store CLI
brew install --cask alt-tab
brew install marta
brew install alfred
brew install karabiner-elements

### Applications
brew install --cask 1password
brew install 1password-cli

### Media
brew install --cask vlc
brew install --cask spotify

### Fonts
brew install --cask font-jetbrains-mono
brew install --cask font-fira-code
brew install --cask font-meslo-lg-nerd-font

# Mac App Store Apps
echo "Installing Mac App Store Apps..."
mas install 1451685025 #Wireguard

# Mac Settings
defaults write com.apple.dock autohide -bool true
defaults write com.apple.Finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"