(local lspconfig (require :lspconfig))
(local configs (require :lspconfig.configs))
(local {: attach} (require :conf.lsp))

(local event vim.api.nvim_create_autocmd)
(local command vim.api.nvim_create_user_command)

(vim.api.nvim_create_augroup "my" {:clear true})
(vim.api.nvim_create_augroup "conf#events" {:clear true})

(command :Event
         (fn [cmd]
           (let [del cmd.bang
                 [event_name & command] cmd.fargs]
             (P cmd)
             (local c (vim.iter command))
             (if del
               (do
                 (local events
                       (vim.iter
                         (vim.api.nvim_get_autocmds
                           {:group :my
                              :event event_name
                              :buffer 0})))
                 (events:map (fn [e] (vim.api.nvim_del_autocmd e.id))))
               (event
                 event_name
                 {:group :my
                  :buffer 0
                  :callback #(vim.cmd (.. "silent " (c:join " ")))}))))
         {:bang true :nargs :* :complete :file :force true})
(let [map vim.keymap.set]
  (map :n :<c-e> ":Event BufWritePost <up>")
  (map :n :<M-e> ":Event! BufWritePost "))

(event
  :LspAttach
  {:group "conf#events"
   :pattern ["*"]
   :callback attach})

(local oil (require :oil))
(event
  :User
  {:group "conf#events"
   :pattern ["ZoxideDirChanged"]
   :callback #(vim.schedule #(oil.open (vim.fn.getcwd)))})

(event
  :BufReadPost
  {:pattern ["*"]
   :callback (fn []
               (local pattern "'\\s\\+$'")
               (vim.cmd (.. "syn match TrailingWhitespace "
                            pattern))
               (vim.cmd "hi link TrailingWhitespace IncSearch"))
   :group "conf#events"})

(event
  :BufWritePost
  {:group "conf#events"
   :callback #(do (local lint (require :lint))
                  (lint.try_lint)
                  (vim.schedule #(vim.diagnostic.setloclist {:open false})))})

(event
  [:BufEnter]
  {:group "conf#events"
   :callback
   #(do (var dir (vim.fn.fnamemodify (vim.fn.expand "%") ":h"))
        (if (vim.startswith dir "oil://") (set dir (dir:sub (+ 1 (length "oil://")))))
        (vim.cmd (.. "silent !lf -remote \"send cd '" dir "'\"")))})


(local session-file (.. vim.env.HOME "/.vimsession.vim"))
(event
  :VimLeave
  {:group "conf#events"
   :pattern ["*"]
   :callback #(vim.cmd (.. "mksession! " session-file))})
;; (event
;;   :VimEnter
;;   {:group "conf#events"
;;    :pattern ["*"]
;;    :callback #(if (= 1 (vim.fn.filereadable session-file))
;;                   (do
;;                     (local start-with-arg (>= 1 (vim.fn.argc)))
;;                     (local file (vim.fn.argv 0))
;;                     (local cwd (vim.fn.getcwd))
;;                     (if start-with-arg (do
;;                                          (vim.schedule #(vim.cmd (.. "source " session-file)))
;;                                          (vim.schedule #(do
;;                                                           (vim.cmd (.. "cd " cwd))
;;                                                           (vim.cmd (.. "e " file))))))))})
