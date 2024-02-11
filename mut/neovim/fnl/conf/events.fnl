(local lspconfig (require :lspconfig))
(local configs (require :lspconfig.configs))
(local {: attach} (require :conf.lsp))

(local event vim.api.nvim_create_autocmd)

(vim.api.nvim_create_augroup "my" {:clear true})
(vim.api.nvim_create_augroup "conf#events" {:clear true})

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


(local session-file (.. vim.env.HOME "/.vimsession.vim"))
(event
  :VimLeave
  {:group "conf#events"
   :pattern ["*"]
   :callback #(vim.cmd (.. "mksession! " session-file))})
(event
  :VimEnter
  {:group "conf#events"
   :pattern ["*"]
   :callback #(if (= 1 (vim.fn.filereadable session-file))
                  (do
                    (local start-with-arg (>= 1 (vim.fn.argc)))
                    (local file (vim.fn.argv 0))
                    (local cwd (vim.fn.getcwd))
                    (vim.schedule #(vim.cmd (.. "source " session-file)))
                    (if start-with-arg (vim.schedule #(do
                                                        (vim.cmd (.. "cd " cwd))
                                                        (vim.cmd (.. "e " file)))))))})
