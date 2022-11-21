(tset (. vim "g") "mapleader" " ")
(tset (. vim "g") "maplocalleader" " ")

(vim.cmd "colorscheme gruvbox-material")

(let [ts (require :nvim-treesitter.configs)] 
  (ts.setup
     {:highlight {:enable true}}))

(require :conf.pkgs)
