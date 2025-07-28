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
brew install rust
brew install node

### Dev Tools
brew tap hashicorp/tap
  brew install hashicorp/tap/terraform
brew install ansible
  brew install hcloud
  brew install kubernetes-cli
brew install talosctl
brew install hashicorp/tap/packer
brew install coreutils
brew install gradle
brew install --cask mactex-no-gui

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
brew install jq

### Mac Enhancements
brew install mas # Mac App Store CLI
brew install alfred
brew install karabiner-elements
brew install hammerspoon --cask

#brew tap FelixKratz/formulae
#brew install sketchybar
brew install --cask nikitabobko/tap/aerospace

### Productivity
brew install --cask postman
brew install --cask moonlight
brew install --cask jdownloader
brew install --cask chatgpt
brew install --cask microsoft-excel
brew install --cask microsoft-word
brew install --cask microsoft-outlook
brew install --cask microsoft-teams
brew install --cask obsidian

### Media
brew install --cask vlc
brew install --cask spotify
brew install --cask comictagger
brew install --cask calibre

### Social
brew install slack
brew install --cask discord

### Fonts
brew install --cask font-jetbrains-mono
brew install --cask font-fira-code
brew install --cask font-meslo-lg-nerd-font
brew install --cask font-hack-nerd-font

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

# Mac App Store Apps
echo "Installing Mac App Store Apps..."
#Wireguard
mas install 1451685025
#Magnet
#mas install 441258766

# Start Services
#brew services start sketchybar

# Emacs
echo "Installing Emacs..."
brew install fd
brew tap railwaycat/emacsmacport
brew install emacs-mac --with-modules
ln -s /opt/homebrew/opt/emacs-mac@29/Emacs.app /Applications/Emacs.app

rm ~/.emacs.d
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install

