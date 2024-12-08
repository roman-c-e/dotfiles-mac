# Installation
## Install Brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

## Install GIT
brew install git

## Clone this repository
### Link dotfiles (check path)
ln -s ~/Developer/personal/dotfiles-mac/config ~/.config
ln -s ~/.config/zsh/zshrc ~/.zshrc

## Install CLI Tools
zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1 -k
brew install --cask kitty
brew install starship gitui neovim zellij

## Neovim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
### NEOVIM Install Plugins :PlugInstall
