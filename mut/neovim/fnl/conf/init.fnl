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
(require :conf.nix-develop)

;; (require :conf.diagnostic)

(local tel (require :telescope))
(local themes (require :telescope.themes))
(local builtin (require :telescope.builtin))
(tel.setup
  {:defaults (vim.tbl_extend :force (themes.get_ivy) {})})

(let [map vim.keymap.set]
  (map :n :<leader>qf ":copen<cr>")
  (map :n :<leader>q<BS> ":cclose<cr>")
  (map :n :<leader>ll ":lopen<cr>")
  (map :n :<leader>l<BS> ":lclose<cr>")
  (map :n :<C-space> ":cnext<cr>")
  (map :n "[q" ":cprevious<cr>")
  (map :n "]q" ":cnext<cr>")
  (map :n "[x" ":lprevious<cr>")
  (map :n "]x" ":lnext<cr>")
  (map :n :<c-p> ":Telescope find_files<cr>" {:noremap true})
  (map :n "`<Backspace>" ":FocusDispatch ")
  (map :n "`k" ":K9s ")
  (map :n "`s" ":Ssh ")
  (map :n "<leader>;" ":silent grep ")
  (map :n :<leader>xb #(builtin.buffers { :sort_mru true :ignore_current_buffer true})))

(set vim.opt.quickfixtextfunc :v:lua.PrettifyQf)

;; I like to use the qf to run a lot of stuff that prints junk
;; Here I just check if ansi control stuff is printed and reparse the lines with efm
(tset _G :PrettifyQf
      (fn [info]
        (local {: id : winid : start_idx : end_idx} info)
        (local qf (vim.fn.getqflist {: id :items 1}))
        (local fname (fn [e]
                       (if (not= 0 e.bufnr)
                           (vim.fn.bufname (. e :bufnr))
                           "")))
        (local s (fn [line pattern]
                   (let [(result n) (line:gsub pattern "")]
                      (match n
                        nil line
                        _ result))))
        (local prettify #(-> $1
                             (s "%c+%[[0-9:;<=>?]*[!\"#$%%&'()*+,-./]*[@A-Z%[%]^_`a-z{|}~]*;?[A-Z]?")))
        (local pos (fn [e] (if (not= 0 e.lnum)
                               (.. e.lnum " col " e.col)
                               "")))
        (local format (fn [e] (accumulate [l ""
                                           _ word
                                           (ipairs [(fname e) "|" (pos e) "| " e.text])]
                                (.. l word))))

        (local items (fn [cfg] (. (vim.fn.getqflist cfg) :items)))

        (icollect
          [_ E (ipairs
                 (items
                  {:lines
                   (icollect [_ e (ipairs qf.items)]
                     (prettify e.text))}))]
          (format E))))

(tset _G :P (lambda [...]
              (let [inspected (icollect [_ v (ipairs [...])]
                                (vim.inspect v))]
                (each [_ printer (ipairs inspected)]
                  (print printer)))))
