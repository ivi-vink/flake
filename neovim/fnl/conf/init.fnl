(vim.cmd "colorscheme gruvbox-material")
(vim.cmd "filetype plugin on")
(vim.cmd "filetype indent on")
(vim.cmd "highlight WinSeparator guibg=None")

(let [nt (require :neotest)
      python (require :neotest-python)]
  (nt.setup {:adapters [(python {:dap {:justMyCode false}})]}))

(require :conf.lsp)
(require :conf.pkgs)
(require :conf.settings)
