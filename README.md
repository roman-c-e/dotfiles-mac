# Clone repository
git clone https://github.com/roman-c-e/dotfiles-mac.git ~/Developer/personal/dotfiles-mac

## Install Scripts
./install.sh
./install-config.sh

## Keyboard Shortcuts
### MEH
1 - 1Password
A - Add Todo: Todoist
B - Browser: Firefox Nightly
C - Calendar: Calendar
D - Development: Editor
E - Email: Email
F - FileManager: Marta
G - Gaming: Steam?
H
I - IDE: IntelliJ IDEA
J
K
L
M - Music: Spotify
N - Notes: GoodNotes
O
P - Phone: iPhone Mirroring
Q
R - Remote: Parsec
S - Social: Messages
T - Terminal: Kitty
U
V - V: Clipboard History
W
X
Y
Z
### HyperKey



## Install GIT
- brew install git

## Clone this repository
### Link dotfiles (check path)
- ln -s ~/Developer/personal/dotfiles-mac/config ~/.config
- ln -s ~/.config/zsh/zshrc ~/.zshrc

## Install CLI Tools
- zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1 -k
- brew install --cask kitty
- brew install starship gitui neovim zellij lsd bat tree-sitter ripgrep imagemagick rar

## Neovim
- curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
### NEOVIM Install Plugins :PlugInstall
