(local lspconfig (require :lspconfig))
(local configs (require :lspconfig.configs))
(local {: attach} (require :conf.lsp))

(local event vim.api.nvim_create_autocmd)

(vim.api.nvim_create_augroup "conf#events" {:clear true})

(event
  :LspAttach
  {:group "conf#events"
   :pattern ["*"]
   :callback attach})

(event
  :BufReadPost
  {:pattern ["*"]
   :callback (fn []
               (local pattern "'\\s\\+$'")
               (vim.cmd (.. "syn match TrailingWhitespace "
                            pattern))
               (vim.cmd "hi link TrailingWhitespace IncSearch"))
   :group "conf#events"})

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
                  (vim.schedule #(vim.cmd (.. "source " session-file))))})
