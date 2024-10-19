(local lualine (require :lualine))
(local clients #(do
                  (local bn (vim.fn.fnamemodify (vim.fn.bufname :%) ::p))
                  (local m (bn:match ".*clients/([a-z]+)/.*"))
                  (if (not= nil m)
                      m
                      "")))
(lualine.setup
  {:extensions [:quickfix :fugitive :oil :fzf :nvim-dap-ui]
   :sections
   {:lualine_c ["%=" {1 clients :color :WarningMsg}]}
   :winbar
   {:lualine_a [:filename]}
   :inactive_winbar
   {:lualine_a [:filename]}
   :tabline
   {:lualine_a [:tabs]}})
