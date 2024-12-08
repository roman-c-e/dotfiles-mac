" vim-plug: Install within nvim with :PlugInstall

" Install vim-plug if not found
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.config/nvim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
"  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
  " Appearance
  Plug 'catppuccin/nvim', { 'as': 'catppuccin' }

  Plug 'nvim-lualine/lualine.nvim'
  Plug 'norcalli/nvim-colorizer.lua'
  Plug 'ryanoasis/vim-devicons' " Icons
  Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

  " Tools
  Plug 'tpope/vim-fugitive' " Git
  Plug 'lewis6991/gitsigns.nvim'

  Plug 'preservim/nerdtree'
  Plug 'Xuyuanp/nerdtree-git-plugin'

  " LaTeX
  Plug 'lervag/vimtex'


  " Fuzzy Finder
  " Fuzzy searching for file names, and within files
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
  Plug 'junegunn/fzf.vim'
  " Use ripgrep to find string in project files, and put results in the quickfix window
Plug 'jremmen/vim-ripgrep'
  Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.2' }

  " LSP Support
  Plug 'neovim/nvim-lspconfig'             " Required
  Plug 'williamboman/mason.nvim',          " Optional
  Plug 'williamboman/mason-lspconfig.nvim' " Optional

  " Snippets
  Plug 'L3MON4D3/LuaSnip'     " Required

  " Autocompletion
  Plug 'hrsh7th/nvim-cmp'     " Required
  Plug 'hrsh7th/cmp-nvim-lsp' " Required
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-path'
  Plug 'hrsh7th/cmp-cmdline'
  Plug 'saadparwaiz1/cmp_luasnip'

  Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'v2.x'}


  " LSP, DAP, Formatter, Linter
Plug 'mfussenegger/nvim-dap' " Debug Adapter Protocol
Plug 'rcarriga/nvim-dap-ui' " DAP UI
Plug 'mfussenegger/nvim-lint' " Linter
Plug 'mhartington/formatter.nvim' " Formatter
Plug 'nvim-lua/plenary.nvim' " Lua functions

  " Snippets, Helpers
"Plug 'scrooloose/nerdcommenter'
"Plug 'sheerun/vim-polyglot'
  Plug 'jiangmiao/auto-pairs'
  
  Plug 'nvim-treesitter/nvim-treesitter' 
  "Helps toggle code comments in various languages
"Plug 'tomtom/tcomment_vim'

" Python auto-complete support
"Plug 'zchee/deoplete-jedi'

" Helps cycle through history of text previously copied
"Plug 'vim-scripts/YankRing.vim'

" Asynchronous linting for different languages
"Plug 'w0rp/ale'

" Snippets
"Plug 'SirVer/ultisnips'
"Plug 'honza/vim-snippets'

" Python support for VIM
"Plug 'davidhalter/jedi-vim'

" Cross-file bookmarks
"Plug 'MattesGroeger/vim-bookmarks'

  Plug 'christoomey/vim-tmux-navigator'
call plug#end()
