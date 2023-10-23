(vim.cmd "colorscheme kanagawa-wave")
(vim.cmd "filetype plugin on")
(vim.cmd "filetype indent on")
(vim.cmd "highlight WinSeparator guibg=None")
(vim.cmd "packadd cfilter")

(require :conf.settings)
(require :conf.pkgs)
(require :conf.nix-develop)
(require :conf.diagnostic)

(tset _G :P (lambda [...]
              (let [inspected (icollect [_ v (ipairs [...])]
                                (vim.inspect v))]
                (each [_ printer (ipairs inspected)]
                  (print printer)))))

(local tel (require :telescope))
(local themes (require :telescope.themes))
(local builtin (require :telescope.builtin))
(local actions (require :telescope.actions))
(tel.setup
  {:defaults
   (vim.tbl_extend
     :force
     (themes.get_ivy)
     {:mappings
      {:i {"<C-a>" actions.select_all}}})})

(local cope #(vim.cmd (.. ":copen " (math.floor (/ vim.o.lines 2.6)))))
(let [map vim.keymap.set]
  (map :v :y "<Plug>OSCYankVisual|gvy")
  (map :n :<leader>qf cope)
  (map :n :<leader>q<BS> ":cclose<cr>")
  (map :n :<leader>ll ":lopen<cr>")
  (map :n :<leader>l<BS> ":lclose<cr>")
  (map :n :<M-space> ":cprev<cr>")
  (map :n :<C-M-space> ":cprev<cr>")
  (map :n :<C-space> ":cnext<cr>")
  (map :n :<C-x> #(do
                    (vim.fn.setreg "/" "Compile")
                    (vim.api.nvim_feedkeys
                      (vim.api.nvim_replace_termcodes
                        ":Compile<up><c-f>" true false true)
                      :n false)
                    (vim.schedule #(do
                                     (vim.cmd "let v:searchforward = 0")
                                     (map :n :/ "/Compile.* " {:buffer true})
                                     (map :n :? "?Compile.* " {:buffer true})))))
  (map :n :<C-e> ":Recompile<CR>")
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
                          (if (not= l "")
                              (prettify l))))
           (local is-at-last-line (let [[n lnum & rest] (vim.fn.getcurpos)
                                        last-line (vim.api.nvim_buf_line_count 0)]
                                    (do
                                      (= lnum last-line))))
           (local is-qf (= (vim.opt_local.buftype:get) "quickfix"))
           (vim.fn.setqflist [] :a {: id : title : lines})
           (if (or
                 (not is-qf)
                 (and is-at-last-line is-qf))
               (vim.cmd ":cbottom")))))

(var last_job nil)
(local job
       (fn [cmd]
         (local title cmd)
         (vim.fn.setqflist [] " " {: title})
         (local add2qf (qf (vim.fn.getqflist {:id 0 :title 1})))
         (local id
            (vim.fn.jobstart
                 cmd
                 {:on_stdout (fn [id data]
                               (if data
                                   (add2qf data)))
                  :on_stderr (fn [id data]
                               (if data
                                   (add2qf data)))
                  :on_exit (fn [id rc]
                            (set last_job.finished true)
                            (set winnr (vim.fn.winnr))
                            (if (not= rc 0)
                                (do
                                  (cope)
                                  (if (not= (vim.fn.winnr) winnr)
                                      (do
                                        (vim.notify "going back")
                                        (vim.cmd "wincmd p"))))
                                (vim.notify (.. "\"" cmd "\" succeeded!"))))}))
         (set
           last_job
           {: cmd
            : id
            :finished false})))

(vim.api.nvim_create_user_command
  :Compile
  (fn [cmd]
    (job cmd.args))
  {:nargs :* :bang true :complete :shellcmd})
(vim.api.nvim_create_user_command
  :Recompile
  (fn []
    (if (= nil last_job)
        (vim.notify "nothing to recompile")
        (if (not last_job.finished)
            (vim.notify "Last job not finished")
            (job last_job.cmd))))
  {:bang true})
(vim.api.nvim_create_user_command
  :Abort
  (fn []
    (if (not= nil last_job)
        (vim.fn.jobstop last_job.id))
    (vim.notify "killed job"))
  {:bang true})
