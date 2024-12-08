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
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
require('lspconfig').pylsp.setup({
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
require('lspconfig').elixirls.setup{
  cmd = {"elixir-ls"},
  capabilities = capabilities
}

lsp.setup()

---
-- Tree Sitter
--
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query"},
  sync_install = false,
  auto_install = true,
  ignore_install = {},

  highlight = {
    enable = true,
    disable = {},
    additional_vim_regex_highlighting = false,
  },
}

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
			}
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

vim.g["netrw_banner"] = 0
vim.g["netrw_liststyle"] = 3

vim.g.NERDTreeShowHidden = 1

vim.g["vimtex_view_method"] = 'zathura'
