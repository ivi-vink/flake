vim.g.codeium_enabled = false
vim.g.loaded_2html_plugin = false
vim.g.loaded_fzf = false
vim.g.loaded_health = false
vim.g.loaded_matchit = false
vim.g.loaded_matchparen = nil
vim.g.loaded_netrwPlugin = false
vim.g.loaded_rplugin = false
vim.g.loaded_shada = false
vim.g.loaded_tohtml = false
vim.g.loaded_tutor = false

vim.g.zoxide_use_select = true
vim.g.zoxide_hook = "pwd"
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.dirvish_mode = ":sort | sort ,^.*[^/]$, r"

vim.opt.grepprg = "rg --vimgrep"
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.shortmess:append("c")
vim.opt.diffopt:append("vertical")
vim.opt.isfname:append("@-@")
vim.opt.wmw = 10
vim.opt.inccommand = "split"
vim.opt.signcolumn = "yes"
vim.opt.smd = false
vim.opt.scrolloff = 8
vim.opt.termguicolors = true
vim.opt.incsearch = true
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand("~/.local/share/nvim/undo")
vim.opt.backup = false
vim.opt.backupcopy = "yes"
vim.opt.swapfile = false
vim.opt.wrap = false
vim.opt.splitbelow = true
vim.opt.magic = true
vim.opt.showbreak = "+++"
-- vim.opt.; listchars {:eol "󰁂"}
vim.opt.list = true
vim.opt.autoread = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.hidden = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.exrc = true
vim.opt.secure = true
-- vim.opt.; completeopt "menu,longest,preview"
vim.opt.wmnu = true
vim.opt.wop = "pum"
-- vim.opt.; wildmode "list:longest"
vim.opt.complete = ".,w,k,kspell,b"
vim.opt.foldopen = "block,hor,jump,mark,percent,quickfix,search,tag"
vim.opt.laststatus = 3
-- vim.opt.; winbar "%=%m %f"
vim.opt.winbar = ""
vim.opt.hlsearch = false
vim.opt.showtabline = 1
vim.opt.cmdheight = 1

vim.opt.shellpipe = "out+err>"
