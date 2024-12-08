-- OPTIONS

-- Behaviour
--vim.o.hlsearch        = false -- Set highlight on search
--vim.o.incsearch     = true
vim.o.ignorecase      = true 	-- Case insensitive searching
vim.o.smartcase       = true	-- If Upper Case Char > case sensitive search
--vim.o.smarttab        = true	-- Smart Tabs
--vim.o.smartindent     = true 	-- Smart Indenting
vim.o.splitbelow      = true 	-- Force Split Below
vim.o.splitright      = true 	-- Force Split Right
vim.o.expandtab       = true
vim.o.tabstop         = 2	    -- Tabstop
vim.o.softtabstop     = 2
vim.o.shiftwidth      = 2
vim.o.scrolloff       = 8  	-- Vertical Scroll Offset
vim.o.sidescrolloff   = 8  	-- Horizontal Scroll Offset
vim.o.mouse           = 'a'	    -- Enable mouse mode
vim.o.clipboard       = 'unnamedplus' -- clipboard between apps
vim.o.wrap            = true -- content of long lines visible

-- Appearance
--vim.o.conceallevel    = 0 	-- Make `` Visible in Markdown
--vim.o.cmdheight       = 1	    -- Better Error Messages
--vim.o.showtabline     = 2     -- Always Show Tabline
--vim.o.pumheight       = 10    -- Pop up Menu Height
vim.wo.number         = true 	-- Display Line Number
vim.wo.relativenumber = true 	-- Make relative line numbers default
vim.o.termguicolors   = true	-- Set Terminal Colors
vim.o.title           = true    -- Display File Info on Title
vim.o.showmode        = false	-- Don't Show MODES
--vim.wo.signcolumn     = 'yes'	-- Sign Column
vim.o.colorcolumn     = '80'    -- border at 80 column for good code style
vim.o.cursorline      = true    -- highlights the current line

-- Vim specific
--vim.o.hidden          = true	 -- Do not save when switching buffers
vim.o.breakindent     = true	-- Enable break indent
--vim.o.backup          = false	    -- Disable Backup
--vim.o.swapfile        = false	    -- Don't create Swap Files
vim.o.spell           = true
vim.o.undofile        = true 	    -- Save undo history
--vim.o.updatetime      = 250	        -- Decrease update time
--vim.o.timeoutlen      = 250	        -- Time for mapped sequence to complete (in ms)
vim.o.inccommand      = 'nosplit'   -- Incremental live completion
vim.o.fileencoding    = 'utf-8'	    -- Set File Encoding
--vim.o.spelllang       = "en"
vim.o.completeopt     = 'noinsert,menuone,noselect'  -- Autocompletion
--vim.opt.shortmess:append { W = true, a = true }
vim.o.undodir         = vim.fn.stdpath("cache") .. "/undo"

-- theme
vim.cmd [[colorscheme catppuccin]]
vim.o.background = "dark"
