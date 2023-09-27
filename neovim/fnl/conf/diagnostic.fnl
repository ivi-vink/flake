(fn m [mode key cb]
  (vim.keymap.set mode key cb {:silent true :noremap true}))

(m :n :<leader>ge (fn []
                    (vim.diagnostic.open_float)))

(vim.diagnostic.config {:virtual_text false})

(vim.keymap.set :n :<Leader>l (let [l (require :lsp_lines)]
                                l.toggle)
                {:desc "Toggle lsp_lines"})

(vim.api.nvim_set_hl 0 :VirtualTextWarning {:link :Grey})
(vim.api.nvim_set_hl 0 :VirtualTextError {:link :DiffDelete})
(vim.api.nvim_set_hl 0 :VirtualTextInfo {:link :DiffChange})
(vim.api.nvim_set_hl 0 :VirtualTextHint {:link :DiffAdd})
