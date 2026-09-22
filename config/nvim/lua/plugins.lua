---
-- LSP
---
local lsp = require('lsp-zero').preset({})
local capabilities = require('cmp_nvim_lsp').default_capabilities()

lsp.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp.default_keymaps({buffer = bufnr})
end)

-- (Optional) Configure lua language server for neovim
local lspconfig = require('lspconfig')

if vim.fn.executable('lua-language-server') == 1 then
  lspconfig.lua_ls.setup(lsp.nvim_lua_ls())
end

if vim.fn.executable('pylsp') == 1 then
  lspconfig.pylsp.setup({
    settings = {
      pylsp = {
        configurationSources = {"flake8"},
          plugins = {
            jedi_completion = {
              include_params = true  -- this line enables snippets
            },
          },
      },
    },
    capabilities = capabilities,
  })
end

if vim.fn.executable('elixir-ls') == 1 then
  lspconfig.elixirls.setup({
    cmd = {"elixir-ls"},
    capabilities = capabilities,
  })
end

lsp.setup()

---
-- Tree Sitter
--
require('nvim-treesitter').setup({})
-- Neovim provides highlighting; only start it when a parser is installed.
-- This keeps a fresh remote machine usable before running :TSInstall.
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
    if lang and pcall(vim.treesitter.get_parser, args.buf, lang) then
      pcall(vim.treesitter.start, args.buf, lang)
    end
  end,
})

---
-- CMP
---
local cmp = require('cmp')
cmp.setup({
  preselect = 'item',
  completion = {
    completeopt = 'menu,menuone,noinsert'
  },
  sources = {
    {name = 'nvim_lsp'},
    {name = 'buffer'},
    {name = 'path'},
    {name = 'luasnip'}
  },
  mapping = {
    ['<CR>'] = cmp.mapping.confirm({select = true}),
  }
  -- own config
})

require('catppuccin').setup {
  color_overrides = {
				mocha = {
					base = "#000000",
					mantle = "#000000",
					crust = "#000000",
				},
			},
  -- Keep diffs easy to scan against the custom pure-black background.
  custom_highlights = function()
    return {
      DiffAdd = { bg = "#17351f" },
      DiffDelete = { bg = "#3b1f27" },
      DiffChange = { bg = "#1d2c45" },
      DiffText = { bg = "#35517a", bold = true },
    }
  end,
}

---
-- Colorizer
---
require('colorizer').setup()

---
-- LuaLine
--
--local winbar = require "config.winbar"
require('lualine').setup {
  options = {
    theme = "catppuccin",
    component_separators = { left = '|', right = '|'}
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {
      {'filename',path = 1}
    },
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {
    lualine_a = {{'buffers'}},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {'tabs'}
  },
  winbar = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  },
  inactive_winbar = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  }
}

---
-- Misc
---
require('gitsigns').setup()

require('diffview').setup({
  enhanced_diff_hl = true,
  diffopt = { algorithm = "histogram" },
  clean_up_buffers = true,
  view = {
    default = {
      layout = "diff1_inline",
      winbar_info = true,
    },
    file_history = {
      layout = "diff1_inline",
      winbar_info = true,
    },
    cycle_layouts = {
      default = { "diff1_inline", "diff2_horizontal", "diff2_vertical" },
    },
    inline = {
      style = "unified",
      deletion_highlight = "full_width",
      deletion_treesitter = true,
    },
  },
  file_panel = {
    listing_style = "tree",
    win_config = { position = "left", width = 35 },
  },
  hooks = {
    diff_buf_read = function()
      vim.opt_local.wrap = false
      vim.opt_local.cursorline = false
      vim.opt_local.colorcolumn = ""
    end,
  },
})

vim.g["netrw_banner"] = 0
vim.g["netrw_liststyle"] = 3

vim.g.NERDTreeShowHidden = 1

vim.g["vimtex_view_method"] = 'zathura'


-- Open NERDTree on startup if no files are specified
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if #vim.api.nvim_list_uis() > 0 and vim.fn.argc() == 0 and vim.fn.exists(":NERDTree") == 2 then
      vim.cmd("NERDTree")
    end
  end
})

-- Other tabs/buffers keep their focus. Use <leader>tr to toggle the file tree.
