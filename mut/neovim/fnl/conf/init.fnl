(vim.cmd "colorscheme kanagawa-wave")
(vim.cmd "filetype plugin on")
(vim.cmd "filetype indent on")
(vim.cmd "highlight WinSeparator guibg=None")
(vim.cmd "packadd cfilter")

(require :conf.settings)
(require :conf.pkgs)

;; (require :conf.lsp)
;; (require :conf.events)
;; (require :conf.filetype)
;; (require :conf.newtab)
;; (require :conf.nix-develop)

;; (require :conf.diagnostic)

(let [map vim.keymap.set]
  (map :t :<c-s> "<c-\\><c-n>")
  ;; pausing and continueing printing output is not necessary inside neovim terminal right?
  (map :t :<c-q> "<c-\\><c-n>:q<cr>")
  (map :n :<leader>qo ":copen<cr>")
  (map :n :<leader>qc ":cclose<cr>")
  (map :n :<leader>lo ":lopen<cr>")
  (map :n :<leader>lc ":lclose<cr>")
  (map :n "[q" ":cprevious<cr>")
  (map :n "]q" ":cnext<cr>")
  (map :n "[x" ":lprevious<cr>")
  (map :n "]x" ":lnext<cr>")
  (map :n :<c-p> ":Telescope find_files<cr>" {:noremap true})
  (map :n "`<Backspace>" ":FocusDispatch ")
  (map :n "`k" ":K9s ")
  (map :n "`s" ":Ssh ")
  (map :n :<leader>p ":NewTab<cr>")
  (map :n :<leader>cf ":tabedit ~/flake|tc ~/flake|G<cr><c-w>o")
  (map :n :<leader>cn ":tabedit ~/neovim|tc ~/neovim|G<cr><c-w>o"))

(tset _G :P (lambda [...]
              (let [inspected (icollect [_ v (ipairs [...])]
                                (vim.inspect v))]
                (each [_ printer (ipairs inspected)]
                  (print printer)))))
