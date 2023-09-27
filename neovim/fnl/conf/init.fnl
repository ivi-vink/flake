(vim.cmd "colorscheme kanagawa-wave")
(vim.cmd "filetype plugin on")
(vim.cmd "filetype indent on")
(vim.cmd "highlight WinSeparator guibg=None")
(vim.cmd "packadd cfilter")

(require :conf.settings)
;; (require :conf.pkgs)
;; (require :conf.lsp)
;; (require :conf.events)
;; (require :conf.filetype)
;; (require :conf.newtab)
;; (require :conf.nix-develop)

;; (require :conf.diagnostic)

;; TODO: make a function that sets this autocommand: au BufWritePost currentfile :!curl -X POST -d "{\"previewRun\": true, \"yamlOverride\": \"$(cat % | yq -P)\", \"resources\": {\"repositories\": {\"self\": {\"refName\": \"refs/heads/branch\"}}}}" -s -H "Content-Type: application/json" -H "Authorization: Basic $WORK_AZDO_GIT_AUTH" "$WORK_AZDO_GIT_ORG_URL/Stater/_apis/pipelines/pipelineid/preview?api-version=7.1-preview.1" | jq -r '.finalYaml // .' > scratch.yaml

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

(local git-worktree (require :git-worktree))
(git-worktree.setup {:change_directory_command :tcd
                     :update_on_change true
                     :autopush true})

(fn append [tbl item]
  (table.insert tbl item)
  tbl)

(fn by-newline [lines]
  (fn iter [items by result]
    (local [item & rest] items)
    (if (= item nil) result
        (= "" item) (iter rest [] (append result by))
        (iter rest (append by item) result)))

  (ipairs (iter lines [] [])))

(vim.keymap.set [:n] :<leader>w
                (fn []
                  (vim.fn.feedkeys ":Worktree switch ")
                  (local cmp (require :cmp))
                  (vim.schedule (fn []
                                  (cmp.close)
                                  (cmp.complete)))))

(vim.keymap.set [:n] :<leader>W ":Worktree ")
(fn list-worktrees []
  (local pworktree (io.popen "git worktree list --porcelain"))
  (icollect [_ worktree (by-newline (icollect [line (pworktree:lines)]
                                      line))]
    (match (icollect [_ line (ipairs worktree)]
             (vim.split line " "))
      [[:worktree path] [:HEAD commit] [:branch branch]] (branch:gsub :refs/heads/
                                                                      ""))))

(fn list-branches []
  (local pbranch (io.popen "git branch --list -r --format \"%(refname)\""))
  (icollect [_ ref (ipairs (icollect [line (pbranch:lines)]
                             (line:gsub :refs/remotes/.+/ "")))]
    (if (not (= ref :HEAD))
        ref)))

(vim.api.nvim_create_user_command :Worktree
                                  (fn [ctx]
                                    (match ctx.fargs
                                      [:create tree branch upstream] (git-worktree.create_worktree tree
                                                                                                   branch
                                                                                                   upstream)
                                      [:create tree upstream] (git-worktree.create_worktree tree
                                                                                            tree
                                                                                            upstream)
                                      [:create tree] (git-worktree.create_worktree tree
                                                                                   tree
                                                                                   :origin)
                                      [:switch tree] (git-worktree.switch_worktree tree)
                                      [:delete tree] (git-worktree.delete_worktree tree)
                                      _ (vim.notify "not recognized")))
                                  {:nargs "*"
                                   :complete (fn [lead cmdline cursor]
                                               (local cmdline-tokens
                                                      (vim.split cmdline " "))
                                               (match cmdline-tokens
                                                 [:Worktree :create & rest] (list-branches)
                                                 [:Worktree :switch & rest] (list-worktrees)
                                                 [:Worktree :delete & rest] (list-worktrees)
                                                 [:Worktree & rest] [:create
                                                                     :switch
                                                                     :delete]))})

(vim.api.nvim_create_user_command :HomeManager
                                  (fn [ctx]
                                    (vim.cmd (.. ":Dispatch home-manager switch --impure "
                                                 (os.getenv :HOME) "/flake#"
                                                 (. ctx.fargs 1))))
                                  {:nargs 1})

(vim.api.nvim_create_user_command :Gpush
                                  (fn [ctx]
                                    (vim.cmd ":Dispatch git push"))
                                  {})

(vim.api.nvim_create_user_command :Grunt
                                  (fn [ctx]
                                    (match (. ctx.fargs 1)
                                      :plan (vim.cmd (.. ":Dispatch "
                                                         (if ctx.bang
                                                             "TF_LOG=DEBUG "
                                                             "")
                                                         "terragrunt "
                                                         (table.concat ctx.fargs
                                                                       " ")
                                                         " " :-out=gruntplan))
                                      :apply (vim.cmd (.. ":Dispatch "
                                                          (if ctx.bang
                                                              "TF_LOG=DEBUG "
                                                              "")
                                                          "terragrunt "
                                                          (table.concat ctx.fargs
                                                                        " ")
                                                          " " :gruntplan))
                                      _ (vim.cmd (.. ":Start "
                                                     (if ctx.bang
                                                         "TF_LOG=DEBUG "
                                                         "")
                                                     "terragrunt "
                                                     (table.concat ctx.fargs
                                                                   " ")))))
                                  {:nargs "*" :bang true})

(vim.api.nvim_create_user_command :K9s
                                  (fn [ctx]
                                    (vim.cmd (.. ":Start k9s --context "
                                                 (. ctx.fargs 1))))
                                  {:nargs 1})

(vim.api.nvim_create_user_command :Ssh
                                  (fn [ctx]
                                    (vim.cmd (.. ":Start ssh " (. ctx.fargs 1))))
                                  {:nargs 1
                                   :complete (fn [lead cmdline cursor]
                                               (local p
                                                      (io.popen :get-sshables))
                                               (local lines
                                                      (icollect [line (p:lines)]
                                                        line))
                                               (p:close)
                                               lines)})
