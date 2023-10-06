(tset vim.g "test#strategy" :neovim)
(tset vim.g "test#neovim#term_position" :botright)

(vim.keymap.set :n :<leader>t ":TestNearest<CR>" {:silent true})
(vim.keymap.set :n :<leader>C ":TestClass<CR>" {:silent true})
(vim.keymap.set :n :<leader>T ":TestFile<CR>" {:silent true})
(vim.keymap.set :n :<leader>a ":TestSuite<CR>" {:silent true})
(vim.keymap.set :n :<leader>l ":TestLast<CR>" {:silent true})
(vim.keymap.set :n :<leader>g ":TestVisit<CR>" {:silent true})
