(local ls (require :luasnip))

(vim.keymap.set ["i"] "<C-K>" #(ls.expand) {:silent true})
(vim.keymap.set ["i" "s"] "<C-L>" #(ls.jump 1) {:silent true})
(vim.keymap.set ["i" "s"] "<C-J>" #(ls.jump -1) {:silent true})
(vim.keymap.set ["i" "s"] "<C-E>" #(if (ls.choice_active) (ls.change_choice 1)) {:silent true})
