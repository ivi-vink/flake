(vim.api.nvim_create_augroup "conf#events" {:clear true})
(local event vim.api.nvim_create_autocmd)

(event [:BufReadPost] {:pattern ["*"]
                       :callback (fn []
                                   (local pattern "'\\s\\+$'")
                                   (vim.cmd (.. "syn match TrailingWhitespace "
                                                pattern))
                                   (vim.cmd "hi link TrailingWhitespace IncSearch"))
                       :group "conf#events"})

(local vimenter-cwd (vim.fn.getcwd))
(event [:VimLeave] {:pattern ["*"]
                    :callback (fn []
                                (vim.cmd (.. "mksession! " vimenter-cwd
                                             :/.vimsession.vim)))
                    :group "conf#events"})

(event [:BufWinEnter :WinEnter]
       {:pattern ["term://*"]
        :callback (fn []
                    (vim.cmd :startinsert))
        :group "conf#events"})

(event [:BufLeave] {:pattern ["term://*"]
                    :callback (fn []
                                (vim.cmd :stopinsert))
                    :group "conf#events"})

(event [:FileType] {:pattern [:dirvish]
                    :callback #(vim.cmd "silent! unmap <buffer> <C-p>")
                    :group "conf#events"})
