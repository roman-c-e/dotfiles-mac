filetype plugin on
set termguicolors
set encoding=UTF-8
source ~/.config/nvim/plugins.vim

lua require('plugins')
lua require('settings')
lua require('keybindings')
