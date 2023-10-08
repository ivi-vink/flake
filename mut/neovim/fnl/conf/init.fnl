(vim.cmd "colorscheme kanagawa-wave")
(vim.cmd "filetype plugin on")
(vim.cmd "filetype indent on")
(vim.cmd "highlight WinSeparator guibg=None")
(vim.cmd "packadd cfilter")

(require :conf.settings)
(require :conf.pkgs)
(require :conf.nix-develop)

(tset _G :P (lambda [...]
              (let [inspected (icollect [_ v (ipairs [...])]
                                (vim.inspect v))]
                (each [_ printer (ipairs inspected)]
                  (print printer)))))

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

;; I like to use the qf to run a lot of stuff that prints junk
;; Here I just check if ansi control stuff is printed and reparse the lines with efm
(local qf
       (fn [{: id : title}]
         (fn [lines]
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

           (local lines (icollect [_ l (ipairs lines)]
                          (if l
                              (prettify l))))
           (vim.fn.setqflist [] :a {: id : title : lines}))))

(local job
       (fn [cmd]
         (local title (table.concat cmd " "))
         (vim.fn.setqflist [] " " {: title})
         (local add2qf (qf (vim.fn.getqflist {:id 0 :title 1})))
         (vim.fn.jobstart
          cmd
          {:on_stdout (fn [id data]
                        (if data
                            (add2qf data)))
           :on_stderr (fn [id data]
                        (if data
                            (add2qf data)))
           :on_exit (fn [id rc]
                      (if (= rc 0)
                          (vim.cmd ":cope")))})))

(var last_job nil)
(vim.api.nvim_create_user_command :Compile (fn [cmd]
                                             (set last_job cmd.fargs)
                                             (job cmd.fargs))
                                  {:nargs :* :bang true})
(vim.api.nvim_create_user_command :Recompile (fn []
                                               (if (not= nil last_job)
                                                   (job last_job)
                                                   (vim.notify "nothing to recompile")))
                                  {:bang true})
