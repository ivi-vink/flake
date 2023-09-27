;; venn.nvim: enable or disable keymappings
(fn toggle-venn []
  (if (not vim.b.venn_enabled)
      (do
        (set vim.b.venn_enabled true)
        (vim.cmd "setlocal ve=all") ; draw a line on HJKL keystokes
        (vim.keymap.set [:n] :J "<C-v>j:VBox<CR>" {:noremap true :buffer 0})
        (vim.keymap.set [:n] :K "<C-v>k:VBox<CR>" {:noremap true :buffer 0})
        (vim.keymap.set [:n] :L "<C-v>l:VBox<CR>" {:noremap true :buffer 0})
        (vim.keymap.set [:n] :H "<C-v>h:VBox<CR>" {:noremap true :buffer 0}) ; draw a box by pres]sing "f" with visual selection)
        (vim.keymap.set [:v] :f ":VBox<CR>" {:noremap true :buffer 0}))
      (do
        (vim.cmd "setlocal ve=")
        (vim.cmd "mapclear <buffer>")
        (set vim.b.venn_enabled nil))))

; toggle keymappings for venn using <leader>v)
(vim.keymap.set [:n] :<leader>v toggle-venn {:noremap true})
