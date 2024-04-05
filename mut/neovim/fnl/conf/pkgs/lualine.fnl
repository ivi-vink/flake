(local lualine (require :lualine))
(lualine.setup
  {:winbar
   {:lualine_a [:filename]}
   :inactive_winbar
   {:lualine_a [:filename]}
   :tabline
   {:lualine_a [:tabs]}})
