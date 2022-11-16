-- general options {{{
vim.opt.clipboard = {}
vim.api.nvim_set_keymap(
    "n",
    "s",
    "<Plug>Ysurround",
    {silent=true,noremap=true}
)

-- don't load standard plugins

vim.g.loaded_2html_plugin = false
vim.g.loaded_fzf = false
vim.g.loaded_man = false
vim.g.loaded_gzip = false
vim.g.loaded_health = false
vim.g.loaded_matchit = false
vim.g.loaded_matchparen = false
vim.g.loaded_netrwPlugin = false
vim.g.loaded_rplugin = false
vim.g.loaded_shada = false
vim.g.loaded_spellfile = false
vim.g.loaded_tarPlugin = false
vim.g.loaded_tohtml = false
vim.g.loaded_tutor = false
vim.g.loaded_zipPlugin = false

vim.cmd [[filetype plugin on]]
vim.cmd [[filetype indent on]]
vim.cmd [[colorscheme gruvbox-material]]
vim.cmd [[highlight WinSeparator guibg=None]]
vim.opt.laststatus = 3
vim.opt.winbar = "%=%m %f"


vim.g.dirvish_mode = ':sort | sort ,^.*[^/]$, r'

vim.opt.foldopen = "block,hor,jump,mark,percent,quickfix,search,tag"
vim.opt.complete = ".,w,k,kspell,b"
vim.opt.completeopt = "menuone,noselect"


vim.opt.secure = true
vim.opt.exrc = true

-- relativenumbers and absolute number
vim.opt.relativenumber = true
vim.opt.number = true

-- don't show previous search pattern
vim.opt.hlsearch = false

-- don't free buffer memory when abandoned
vim.opt.hidden = true

-- 1 tab == 4 spaces
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

-- use spaces instead of tabs
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.autoindent = true

-- show special characters as listed
vim.opt.list = true
vim.opt.listchars = { tab = ' ', eol = "﬋" }
vim.opt.showbreak = '﬋'

-- make pasting better but makes insert mappings stop working...
-- vim.opt.paste = true

-- magic vim patterns
vim.opt.magic = true

-- make splitting consistent
vim.opt.splitbelow = true

vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv('HOME') .. "/.local/share/nvim/undo"
vim.opt.undofile = true
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.smd = false
vim.opt.signcolumn = "yes"
vim.opt.inccommand = "split"
vim.opt.wmw = 10
vim.opt.isfname:append("@-@")
vim.opt.diffopt:append("vertical")
vim.opt.shortmess:append("c")
-- }}}


-- load global and utility functions

local racket_lang = vim.g.racket_hash_lang_dict
racket_lang.sicp = "racket"
vim.g.racket_hash_lang_dict = racket_lang
vim.api.nvim_set_keymap("n", "g<space>", ":TestNearest<cr>", {})
-- TODO: debug test
-- vim.api.nvim_set_keymap("n", "g<cr>", ":TestNearest<cr>", {})
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.shell = Flake.bash
local vimrc = require('vimrc')
-- save session file in cwd
vimrc.cwd_save_session()

-- tree-sitter {{{
require('vimrc').setup_treesitter()
-- }}}

-- {{{ git
vim.cmd([[command! -bang Gap :G commit -am 'fixmeuplater' | G push]])
-- }}}

-- completion {{{
vim.api.nvim_set_keymap('n', ']p', ':tabn<cr>', { silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '[p', ':tabp<cr>', { silent = true, noremap = true})

require'vimrc'.setup_cmp()

require'vimrc.snippets'.setup()

-- }}}

-- buffers {{{
vim.opt.switchbuf = "useopen,usetab"
vim.opt.stal = 2

vim.api.nvim_set_keymap(
    "n",
    "<leader>;",
    "<C-^>",
    { silent = true, noremap = true }
)

-- taken from: https://github.com/Furkanzmc/dotfiles/blob/master/vim/init.lua
-- searching and replacing in buffers
vim.api.nvim_set_keymap(
    "v",
    "<leader>s",
    ":call buffers#visual_selection('search', '')<CR>",
    { silent = true, noremap = true }
)
vim.api.nvim_set_keymap(
    "v",
    "<leader>r",
    ":call buffers#visual_selection('replace', '')<CR>",
    { silent = true, noremap = true }
)
vim.cmd([[command! -nargs=1 -complete=file E execute('silent! !mkdir -p "$(dirname "<args>")"') <Bar> e <args>]])
-- wiping buffers and wiping nofile-buffers
vim.cmd([[command! -nargs=1 -bang Bdeletes :call buffers#wipe_matching('<args>', <q-bang>)]])
vim.cmd([[command! Bdnonexisting :call buffers#wipe_nonexisting_files()]])

vim.cmd([[command! CleanTrailingWhiteSpace :lua require"vimrc.buffers".clean_trailing_spaces()]])

vim.cmd([[augroup vimrc_plugin_buffers]])
vim.cmd([[au!]])
vim.cmd(
    [[autocmd BufWritePre *.md,*.hcl,*.tf,*.py,*.cpp,*.qml,*.js,*.txt,*.json,*.html,*.lua,*.yaml,*.yml,*.bash,*.sh,*.go :lua require"vimrc.buffers".clean_trailing_spaces()]]
)
vim.cmd(
    [[autocmd BufReadPost * lua require"vimrc.buffers".setup_white_space_highlight(vim.fn.bufnr())]]
)
vim.cmd(
    [[autocmd BufReadPre *.tf,*.hcl packadd vim-terraform]]
)
vim.cmd([[augroup END]])

-- }}}

-- quickfix {{{
vim.api.nvim_set_keymap(
    "n",
    "<C-q>o",
    ":copen<cr>",
    { silent = true, noremap = true }
)
vim.api.nvim_set_keymap(
    "n",
    "<C-q>z",
    ":cclose<cr>",
    { silent = true, noremap = true }
)

vim.api.nvim_set_keymap(
    "n",
    "<C-q>lo",
    ":lopen<cr>",
    { silent = true, noremap = true }
)
vim.api.nvim_set_keymap(
    "n",
    "<C-q>lz",
    ":lclose<cr>",
    { silent = true, noremap = true }
)
vim.api.nvim_set_keymap("n", "]q", ":cnext<cr>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "[q", ":cprevious<cr>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "]Q", ":cfirst<cr>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "[Q", ":clast<cr>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "]l", ":lnext<cr>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "[l", ":lprevious<cr>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "]L", ":lfirst<cr>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "[L", ":llast<cr>", { silent = true, noremap = true })
-- }}}

-- firvish {{{
require'firvish'.setup()
vim.g.firvish_use_default_mappings=1
require'vimrc'.setup_jq_function()
require'vimrc'.setup_build_function()
-- }}}

-- {{{ trouble
require"trouble".setup { }
-- }}}

-- {{{ tests
-- require"nvim-test".setup{}
-- vim.api.nvim_set_keymap(
--     "n",
--     "<leader>t",
--     "<cmd>TestFile<CR>",
--     {silent = true, noremap = true}
-- )
-- }}}

-- lsp {{{
vim.cmd [[augroup vimrc_nvim_lsp_setup]]
vim.cmd [[au!]]
vim.cmd [[au VimEnter * lua require'vimrc.lsp'.setup()]]
vim.cmd [[augroup END]]
-- }}}

-- dap {{{
require('vimrc.dap').setup_dap()
vim.cmd [[augroup vimrc_nvim_dap_setup]]
vim.cmd [[au!]]
vim.cmd [[au VimEnter * lua require('vimrc.dap').setup_dap()]]
vim.cmd [[augroup END]]
-- }}}

-- terminal {{{
-- open close terminal
vim.cmd [[command! Term :lua require('vimrc.term').toggle()]]
-- run current file
vim.cmd [[command! Run :lua require('vimrc.term').run()]]
-- send selection
vim.cmd [[command! -range Send :lua require('vimrc.term').sendSelection()]]
vim.api.nvim_set_keymap(
    "t",
    "<c-q><c-w>",
    "<c-\\><c-n>",
    { silent = true, noremap = true }
)
-- }}}

-- statusline {{{
-- require('el').setup {}
-- TODO: move to colortemplates
vim.cmd [[hi! link Winbar StatusLine]]
-- }}}

-- init autocommand {{{
vim.cmd([[augroup vimrc_init]])
vim.cmd([[autocmd!]])
vim.cmd(
    [[autocmd BufReadPre,FileReadPre *.rest :if !exists("g:vimrc_rest_nvim_loaded") | packadd vim-rest-console | let g:vimrc_rest_nvim_loaded = v:true | endif | :e]]
)
vim.cmd(
    [[autocmd TextYankPost * silent! lua vim.highlight.on_yank{on_visual=false, higroup="IncSearch", timeout=100}]]
)
vim.cmd(
    [[ autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankReg "' | endif ]]
)
vim.cmd(
    [[autocmd VimEnter * if filereadable(".exrc.lua") | call execute("luafile .exrc.lua") | endif]]
)
vim.cmd(
    [[autocmd VimEnter * if filereadable(".env") | echo execute("Dotenv") | call execute("Dotenv .env") | endif]]
)
-- temp fix for screen redrawing issues
-- cmd(
--     [[autocmd BufEnter * mod]]
-- )
vim.cmd([[augroup END]])
-- }}}
-- vim: fdm=marker
