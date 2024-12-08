# Installation
## Install Brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

## Install GIT
brew install git

## Clone this repository
### Link dotfiles
ln -s ~/PATH/dotfiles-mac/config ~/.config
ln -s ~/.config/zsh/zshrc ~/.zshrc

## Install CLI Tools
zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1 -k
brew install --cask kitty
brew install starship

