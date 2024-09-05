(require :conf.settings)
(require :conf.nix-develop)
(require :conf.diagnostic)
(require :conf.events)
(require :conf.pkgs)

(vim.schedule #(vim.cmd "colorscheme kanagawa-wave"))
(vim.cmd "filetype plugin on")
(vim.cmd "filetype indent on")
(vim.cmd "highlight WinSeparator guibg=None")
(vim.cmd "packadd cfilter")

(vim.opt.clipboard:append ["unnamedplus"])

(local osc52 (require :vim.ui.clipboard.osc52))
(let
  [paste 
   (fn [] [(vim.fn.split (vim.fn.getreg "") "\n") (vim.fn.getregtype "")])
   xclip 
   (fn [lines] 
     (vim.system [:xclip] {:text true :stdin lines} (fn [exitobj]))
     (vim.system [:xclip :-selection :clipboard] {:text true :stdin lines} (fn [exitobj]))
     nil)]
  (set
     vim.g.clipboard
     {:name "OSC 52"
      :copy {:+ xclip
             :* xclip}
      :paste {:+ paste
              :* paste}}))


(tset _G :P (lambda [...]
              (let [inspected (icollect [_ v (ipairs [...])]
                                (vim.inspect v))]
                (each [_ printer (ipairs inspected)]
                  (print printer)))))

(local fzf (require :fzf-lua))
(local action (require :fzf-lua.actions))
(fzf.setup [:max-perf])

(local
 draw
 (fn [toggle]
   (if
     toggle
     (do
       (vim.cmd "set virtualedit=all")
       (vim.keymap.set :v "<leader>;" "<esc>:VBox<CR>")
       (vim.keymap.set "n" "J" "<C-v>j:VBox<CR>")
       (vim.keymap.set "n" "K" "<C-v>k:VBox<CR>")
       (vim.keymap.set "n" "L" "<C-v>l:VBox<CR>")
       (vim.keymap.set "n" "H" "<C-v>h:VBox<CR>"))
     (do
       (vim.cmd "set virtualedit=")
       (vim.keymap.del :v "<leader>;")
       (vim.keymap.del "n" "J")
       (vim.keymap.del "n" "K")
       (vim.keymap.del "n" "L")
       (vim.keymap.del "n" "H")))))

(local commenter (require :nvim_comment))
(commenter.setup)
(local cinnamon (require :cinnamon))
(cinnamon.setup {
                 :extra_keymaps true
                 :override_keymaps true
                 :max_length 200
                 :horizontal_scroll false
                 :default_delay 7
                 :scroll_limit -1})


(fn i-grep [word file]
   (vim.api.nvim_feedkeys
     (vim.api.nvim_replace_termcodes
       (.. ":silent grep " (if (not= "" word) (.. word " ") "") (file:gsub "oil://" "") "<c-f>B<left>i<space>") true false true)
     :n false))

(local cope #(vim.cmd (.. ":botright copen " (math.floor (/ vim.o.lines 2.1)))))
(local oil (require :oil.actions))
(let [map vim.keymap.set]
  (map :n :gb ":GBrowse<CR>")
  (map :n :ga "<Plug>(EasyAlign)")
  (map :x :ga "<Plug>(EasyAlign)")
  (map :n :<leader>d<cr> (fn [] (draw true)))
  (map :n :<leader>d<bs> (fn [] (draw false)))
  (map :n :- ::Oil<cr>)
  (map :n :_ #(oil.open_cwd.callback))
  (map :n :<leader>qf cope)
  (map :n :<leader>q<BS> ":cclose<cr>")
  (map :n :<leader>ll ":lopen<cr>")
  (map :n :<leader>l<BS> ":lclose<cr>")
  (map :n "<M-h>" cope)
  (map :n "<C-n>" ":cnext<cr>")
  (map :n "<C-p>" ":cprev<cr>")
  (map :n :<C-a> ":Recompile<CR>")
  (map :n :<C-s>
       #(do
          (vim.api.nvim_feedkeys
            (vim.api.nvim_replace_termcodes
              ":Sh<up><c-f>" true false true)
            :n false)
          (vim.schedule #(do
                           (vim.cmd "let v:searchforward = 0")
                           (map :n :/ "/Sh.*" {:buffer true})
                           (map :n :? "?Sh.*" {:buffer true})))))
  (map :n :<C-x>
       #(do
          (vim.api.nvim_feedkeys
            (vim.api.nvim_replace_termcodes
              ":Compile<up><c-f>" true false true)
            :n false)
          (vim.schedule #(do
                           (vim.cmd "let v:searchforward = 0")
                           (map :n :/ "/Compile.*" {:buffer true})
                           (map :n :? "?Compile.*" {:buffer true})))))
  (map :n "[q" ":cprevious<cr>")
  (map :n "]q" ":cnext<cr>")
  (map :n "[x" ":lprevious<cr>")
  (map :n "]x" ":lnext<cr>")
  (map :n "[g" ":GV<cr>")
  (map :n "]g" ":GV?<cr>")
  (map :n "]G" ":GV!<cr>")
  (map :n :<leader>xp #(fzf.files))
  (map :n "<leader>:" #(i-grep "<c-r><c-w>" (vim.fn.bufname "%")))
  (map :v "<leader>:" ":Vgrep!<cr>")
  (map :n "<leader>;" #(i-grep "" (vim.fn.fnamemodify (vim.fn.bufname "%") ":h")))
  (map :v "<leader>;"  ":Vgrep<cr>")
  (map :n "<leader>'" ":silent args `fd `<left>")
  (map :n :<leader>xa #(fzf.args))
  (map :n "<leader>x;" #(fzf.quickfix))
  (map :n :<leader>xb #(fzf.buffers
                         {:keymap {:fzf {"alt-a" "toggle-all"}}
                          :actions {:default {:fn action.buf_edit_or_qf}}}))
  (map :n :<leader>x<cr> #(vim.cmd "b #"))
  (map :n :<C-w>d
       #(do
          (local uis (vim.iter (vim.api.nvim_list_uis)))
          (uis:map (fn [ui] (vim.fn.chanclose ui.chan))))))

(do
  (local obsidian (require "obsidian"))
  (obsidian.setup
    { :workspaces
      [{
        :name "notes"
        :path (if (= 1 (vim.fn.isdirectory (vim.fn.expand "~/Sync/my/notes"))) "~/Sync/my/notes"  "~/sync/my/notes")}]}))


(do
  (local fzf (require "fzf-lua"))
  ((. fzf "register_ui_select")))

(vim.api.nvim_create_user_command
  :Vgrep
  (fn [{: bang}]
   (local [buf <row <col] (vim.fn.getpos "'<"))
   (local [buf >row >col] (vim.fn.getpos "'>"))
   (local [line & rest] (vim.api.nvim_buf_get_text 0 (- <row 1) (- <col 1) (- >row 1) >col {}))
   (if bang
     (i-grep line (vim.fn.bufname "%"))
     (i-grep line (vim.fn.fnamemodify (vim.fn.bufname "%") ":h"))))
  {:range 1 :bang true})

(vim.api.nvim_create_user_command
  :NixEdit
  (fn [{: args}]
    (local f (io.popen (.. "nix eval --raw /nix-config#nixosConfigurations." (vim.fn.hostname) ".pkgs." args)))
    (vim.cmd (.. "e " (f:read))))
  {:nargs 1})

(local qf
       (fn [{: id : title}]
         (fn [lines]
           (local s (fn [line pattern]
                      (let [(result n) (line:gsub pattern "")]
                         (match n
                           nil line
                           _ result))))
           (local prettify #(-> $1
                                (s "%c+%[[0-9:;<=>?]*[!\"#$%%&'()*+,-./]*[@A-Z%[%]^_`a-z{|}~]*;?[A-Z]?")))
           (vim.schedule
             #(do
                (local is-qf (= (vim.opt_local.buftype:get) "quickfix"))
                (local is-at-last-line (let [[row col] (vim.api.nvim_win_get_cursor 0)
                                             last-line (vim.api.nvim_buf_line_count 0)]
                                         (do
                                           (= row last-line))))
                (vim.fn.setqflist
                  [] :a
                  {: id : title
                   :lines
                   (icollect [l lines]
                     (do
                       (if (not= l "")
                           (prettify l))))})
                (if (or
                      (not is-qf)
                      (and is-at-last-line is-qf))
                    (vim.cmd ":cbottom")))))))

(var last_job_state nil)
(var last_job_thunk nil)
(local qfjob
       (fn [cmd stdin]
         (local title (table.concat cmd " "))
         (vim.fn.setqflist [] " " {: title})
         (local add2qf (qf (vim.fn.getqflist {:id 0 :title 1})))
         (set
           last_job_state
           (vim.system
                cmd
                {: stdin
                 :stdout (fn [err data]
                           (if data
                               (add2qf (string.gmatch data "[^\n]+"))))
                 :stderr (fn [err data]
                           (if data
                               (add2qf (string.gmatch data "[^\n]+"))))}
                (fn [obj]
                 (vim.schedule
                   #(do
                      (set winnr (vim.fn.winnr))
                      (if (not= obj.code 0)
                          (do
                            (cope)
                            (if (not= (vim.fn.winnr) winnr)
                                (do
                                  (vim.notify (.. title " failed, going back"))
                                  (vim.cmd "wincmd p | cbot"))
                                (vim.notify (.. title "failed, going back"))))
                          (vim.notify (.. "\"" title "\" succeeded!"))))))))))

(vim.api.nvim_create_user_command
  :Compile
  (fn [cmd]
    (local thunk #(qfjob cmd.fargs nil))
    (set last_job_thunk thunk)
    (thunk))
  {:nargs :* :bang true :complete "file"})
(vim.api.nvim_create_user_command
  :Sh
  (fn [cmd]
    (local thunk #(qfjob [:zshcmd cmd.args] nil))
    (set last_job_thunk thunk)
    (thunk))
  {:nargs :* :bang true :complete :shellcmd})
(vim.api.nvim_create_user_command
  :Recompile
  (fn []
    (if (= nil last_job_state)
        (vim.notify "nothing to recompile")
        (if (not (last_job_state:is_closing))
            (vim.notify "Last job not finished")
            (last_job_thunk))))
  {:bang true})
(vim.api.nvim_create_user_command
  :Stop
  (fn []
    (if (not= nil last_job_state)
        (do
          (last_job_state:kill)
          (vim.notify "killed job"))
        (vim.notify "nothing to do")))
  {:bang true})
(vim.api.nvim_create_user_command
  :Args
  (fn [obj]
    (if (not= 0 (length obj.fargs))
        (do
          (local thunk #(qfjob [:sh :-c obj.args] (vim.fn.argv)))
          (set last_job_thunk thunk)
          (thunk))))
  {:nargs :* :bang true :complete :shellcmd})



(fn browse_git_remote
  [data]
  (P data)
  (local 
    {: commit
     : git_dir
     : line1
     : line2
     : path
     : remote
     : remote_name
     : repo
     : type } data)

  (local
    oilpath
    (case (vim.fn.bufname "%")
      (where oilbuf (vim.startswith oilbuf "oil://"))
      (do
        (local d (.. "oil://" (vim.fs.dirname git_dir) "/"))
        (oilbuf:sub (+ 1 (d:len)) (oilbuf:len)))
      _
      ""))

  (local [home repo]
    (case remote
      (where s (vim.startswith s "git@"))
      (do
        (or
          (case [(s:match "(git@)([^:]+):(.*)(%.git)")]
              ["git@" home repo ".git"] 
              [home repo])
          (case [(s:match "(git@)([^:]+):.*/(.*)/(.*)/(.*)")]
              ["git@" home org project repo] 
              [(home:gsub "ssh%." "") [(.. org "/" project) repo]])))))

  (case [home repo]
    (where ["bitbucket.org" repo]) 
    (do
      (case [path type]
        ["" "tree"]
        (.. "https://" home "/" repo "/src/" commit "/" (or oilpath path ""))
        [path "blob"]
        (.. "https://" home "/" repo "/src/" commit "/" path)
        [path "commit"]
        (.. "https://" home "/" repo "/commits/" commit)
        [path "ref"]
        (.. "https://" home "/" repo "/commits/" commit)))
    (where ["dev.azure.com" [org repo]]) 
    (do
      (case [path type]
        ["" "tree"]
        (.. "https://" home "/" org "/_git/" repo "?version=GB" commit "&path=/" (or oilpath path ""))
        [path "blob"]
        (.. "https://" home "/" org "/_git/" repo "?version=GB" commit "&path=/" path)
        [path "commit"]
        (.. "https://" home "/" org "/_git/" repo "/commit/" commit)
        [path "ref"]
        (.. "https://" home "/" org "/_git/" repo "/commit/" commit)))
    (where ["gitlab.com" repo]) 
    (do
      (case [path type]
        ["" "tree"]
        (.. "https://" home "/" repo "/-/tree/" commit "/" (or oilpath ""))
        [path "commit"]
        (.. "https://" home "/" repo "/-/commit/" commit)
        [path "ref"]
        (.. "https://" home "/" repo "/-/commit/" commit)
        [path "blob"]
        (.. "https://" home "/" repo "/-/blob/" commit "/" path)))
    (where ["github.com" repo]) 
    (do
      (case [path type]
        ["" "tree"]
        (.. "https://" home "/" repo "/tree/" commit "/" (or oilpath ""))
        [path "commit"]
        (.. "https://" home "/" repo "/commit/" commit)
        [path "ref"]
        (.. "https://" home "/" repo "/commit/" commit)
        [path "blob"]
        (.. "https://" home "/" repo "/blob/" commit "/" path)))))

(vim.api.nvim_create_user_command
  :Browse
  (fn [{: args}] (vim.system ["xdg-open" args] {} (fn [])))
  {:nargs 1})

(set vim.g.fugitive_browse_handlers 
     [browse_git_remote])
