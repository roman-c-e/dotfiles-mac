#!/bin/zsh

# Install Config (cloning this repo)
## Clone repositories
git clone https://github.com/roman-c-e/dotfiles-mac.git ~/Developer/personal/dotfiles-mac

## Link dotfiles
ln -s ~/Developer/personal/dotfiles-mac/config ~/.config
ln -s ~/.config/zsh/zshrc ~/.zshrc

## Install CLI Tools
zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1 -k

## Neovim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
echo "NEOVIM Install Plugins :PlugInstall"