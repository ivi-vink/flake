(import-macros {: settings : globals} :conf.macros)

(globals
  codeium_enabled false
  loaded_2html_plugin true
  loaded_fzf false
  ;; loaded_man true
  ;; loaded_gzip true
  loaded_health false
  loaded_matchit false
  loaded_matchparen false
  loaded_netrwPlugin false
  loaded_rplugin false
  loaded_shada false
  ;; loaded_spellfile true
  ;; loaded_tarPlugin true
  loaded_tohtml false
  loaded_tutor false
  ;; loaded_zipPlugin true

  zoxide_use_select true
  zoxide_hook "pwd"
  mapleader " "
  maplocalleader " "
  dirvish_mode ":sort | sort ,^.*[^/]$, r")

(settings
  grepprg "rg --vimgrep"
  grepformat "%f:%l:%c:%m"
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
  backupcopy yes
  swapfile off
  wrap off
  splitbelow on
  magic on
  showbreak "+++"
  ; listchars {:eol "󰁂"}
  list on
  autoread on
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
  ; completeopt "menu,longest,preview"
  wmnu on
  wop "pum"
  ; wildmode "list:longest"
  complete ".,w,k,kspell,b"
  foldopen "block,hor,jump,mark,percent,quickfix,search,tag"
  laststatus 3
  ; winbar "%=%m %f"
  winbar ""
  hlsearch off
  showtabline 1
  cmdheight 1)
