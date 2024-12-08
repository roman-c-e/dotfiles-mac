vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local opt = {
  noremap = true
}

-- Basics
vim.keymap.set('i', 'jj', '<Esc>', opt)
vim.keymap.set('n', '<leader>xx', ":bd<CR>", opt)
vim.keymap.set('n', '<leader>ss', ":w<CR>", opt)
vim.keymap.set('n', '<leader>sx', ":wq<CR>", opt)
-- Tools
vim.keymap.set('n', '<leader>gs', vim.cmd.Git, opt)
vim.keymap.set('n', '<leader>tr', vim.cmd.NERDTreeToggle, opt)

-- move lines
vim.keymap.set("n", '<A-j>', ":m .+1<CR>==", opt)
vim.keymap.set("n", '<A-k>', ":m .-2<CR>==", opt)
vim.keymap.set("i", '<A-j>', "<Esc>:m .+1<CR>==gi", opt)
vim.keymap.set("i", '<A-k>', "<Esc>:m .-2<CR>==gi", opt)
vim.keymap.set("v", '<A-j>', ":m '>+1<CR>gv=gv", opt)
vim.keymap.set("v", '<A-k>', ":m '<-2<CR>gv=gv", opt)

-- Fuzzy Finder - Telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
