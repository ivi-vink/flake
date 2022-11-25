(import-macros {: settings : globals} :conf.macros)

(globals
  loaded_2html_plugin true
  loaded_fzf false
  loaded_man false
  loaded_gzip false
  loaded_health false
  loaded_matchit false
  loaded_matchparen false
  loaded_netrwPlugin false
  loaded_rplugin false
  loaded_shada false
  loaded_spellfile false
  loaded_tarPlugin false
  loaded_tohtml false
  loaded_tutor false
  loaded_zipPlugin false

  dirvish_mode ":sort | sort ,^.*[^/]$, r")

(settings 
  +shortmess "c"
  +diffopt vertical
  +isfname "@-@"
  wmw 10
  inccommand split
  signcolumn yes
  smd off
  scrolloff 8
  termguicolors on
  incsearch on
  undofile on
  undodir (.. (os.getenv :HOME)  :/.local/share/nvim/undo)
  backup off
  swapfile off
  wrap off
  splitbelow on
  magic on
  showbreak "﬋"
  listchars { :tab " " :eol "﬋"}
  list on
  autoindent on
  smartindent on
  expandtab on
  tabstop 4
  softtabstop 4
  shiftwidth 4
  hidden on
  number on
  relativenumber on
  exrc on
  secure on
  completeopt "menuone,noselect"
  complete ".,w,k,kspell,b"
  foldopen "block,hor,jump,mark,percent,quickfix,search,tag"
  laststatus 3
  winbar "%=%m %f"
  hlsearch off
  clipboard "")
