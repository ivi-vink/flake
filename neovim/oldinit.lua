-- fixes:
-- ; eval (current-form): (let [hotpot (require :hotpot) eval ...
-- ; ...ike/.cache/nvim/hotpot/hotpot.nvim/lua/hotpot/common.lua:15: module 'hotpot.api' not found:
-- ; 	no field package.preload['hotpot.api']
-- ; 	no file '/home/mike/.cache/nvim/hotpot/hotpot.nvim/lua/hotpot/api.lua'
-- ; 	no file '/nix/store/w08dyn0iamcixgc6cgv9ma8sq165vlvq-luajit-2.1.0-2022-10-04-env/share/lua/5.1/hotpot/api.lua'
-- ; 	no file '/nix/store/w08dyn0iamcixgc6cgv9ma8sq165vlvq-luajit-2.1.0-2022-10-04-env/share/lua/5.1/hotpot/api/init.lua'
-- ; 	no file '/nix/store/w08dyn0iamcixgc6cgv9ma8sq165vlvq-luajit-2.1.0-2022-10-04-env/lib/lua/5.1/hotpot/api.so'
-- ; 	no file '/nix/store/w08dyn0iamcixgc6cgv9ma8sq165vlvq-luajit-2.1.0-2022-10-04-env/lib/lua/5.1/hotpot.so'
package.path = "/home/mike/.cache/nvim/hotpot/hotpot.nvim/lua/?/init.lua;" .. package.path 
require("hotpot").setup({
  -- allows you to call `(require :fennel)`.
  -- recommended you enable this unless you have another fennel in your path.
  -- you can always call `(require :hotpot.fennel)`.
  provide_require_fennel = false,
  -- show fennel compiler results in when editing fennel files
  enable_hotpot_diagnostics = true,
  -- compiler options are passed directly to the fennel compiler, see
  -- fennels own documentation for details.
  compiler = {
    -- options passed to fennel.compile for modules, defaults to {}
    modules = {
      -- not default but recommended, align lua lines with fnl source
      -- for more debuggable errors, but less readable lua.
      -- correlate = true
    },
    -- options passed to fennel.compile for macros, defaults as shown
    macros = {
      env = "_COMPILER", -- MUST be set along with any other options
      -- you may wish to disable fennels macro-compiler sandbox in some cases,
      -- this allows access to tables like `vim` or `os` inside macro functions.
      -- See fennels own documentation for details on these options.
      compilerEnv = _G,
      allowGlobals = false,
    }
  }
})

local cmp = require 'cmp'
cmp.setup({
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        end,
    },
    completion = {
        autocomplete = false
    },
    window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-A>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
        { name = 'conjure' },
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'path' },
    })
})

function setup_treesitter()
    if vim.o.loadplugins == false then
        return
    end

    if vim.fn.exists(":TSInstall") == 1 then
        return vim.notify "TreeSitter is already configured."
    end

    -- vim.cmd([[packadd nvim-treesitter]])
    require 'nvim-treesitter.configs'.setup {
        highlight = {
            enable = true,
            -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
            -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
            -- Using this option may slow down your editor, and you may see some duplicate highlights.
            -- Instead of true it can also be a list of languages
        },
        rainbow = {
            enable = true,
            -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
            extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
            max_file_lines = nil, -- Do not enable for files with more than n lines, int
            -- colors = {}, -- table of hex strings
            -- termcolors = {} -- table of colour name strings
        },

        incremental_selection = {
            enable = true,
        },
        indent = {
            enable = false,
            disable = { "python", "yaml" },
        },
    }
    vim.cmd [[hi link TSParameter Todo]]
end
setup_treesitter()
cwd_save_session = function()
    vim.cmd([[
augroup vimrc_save_session
    au!
    au VimLeave * mksession! ]] .. os.getenv("PWD") .. [[/Session.vim
augroup end
    ]])
end
cwd_save_session()

vim.cmd [[filetype plugin on]]
vim.cmd [[filetype indent on]]
vim.cmd [[colorscheme gruvbox-material]]
vim.cmd [[highlight WinSeparator guibg=None]]

-- }}}


-- load global and utility functions

-- racket nvim workaround
local racket_lang = vim.g.racket_hash_lang_dict
racket_lang.sicp = "racket"
vim.g.racket_hash_lang_dict = racket_lang

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.shell = Flake.bash
-- local vimrc = require('vimrc')

-- tree-sitter {{{
-- }}}
