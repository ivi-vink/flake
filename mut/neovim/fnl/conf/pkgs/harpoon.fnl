(local harpoon-mark (require :harpoon.mark))
(local harpoon-ui (require :harpoon.ui))
(fn make-harpoon [func]
  (fn []
    (func)
    (vim.cmd :redrawtabline)))

(vim.keymap.set :n "[]" (make-harpoon (fn [] (harpoon-mark.add_file))))
(vim.keymap.set :n "][" (make-harpoon (fn [] (harpoon-ui.toggle_quick_menu))))
(vim.keymap.set :n "]]" (make-harpoon (fn [] (harpoon-ui.nav_next))))
(vim.keymap.set :n "[[" (make-harpoon (fn [] (harpoon-ui.nav_prev))))

(var use-numbers false)
(local num [1 2 3 4 5])
(local shortcuts ["+" "-" "<" ">" "\""])
(fn print-use-numbers []
  (print (vim.inspect use-numbers)))

(fn toggle-harpoon-mappings []
  (if (not use-numbers)
      (do
        ; (each [_ i (ipairs shortcuts)] ;   (vim.keymap.del :n i))
        (vim.keymap.set :n "[+" (make-harpoon (fn [] (harpoon-ui.nav_file 1))))
        (vim.keymap.set :n "[-" (make-harpoon (fn [] (harpoon-ui.nav_file 2))))
        (vim.keymap.set :n "[<" (make-harpoon (fn [] (harpoon-ui.nav_file 3))))
        (vim.keymap.set :n "[>" (make-harpoon (fn [] (harpoon-ui.nav_file 4))))
        (vim.keymap.set :n "[\"" (make-harpoon (fn [] (harpoon-ui.nav_file 5))))
        (set use-numbers true))
      (do
        ; (each [_ s (ipairs shortcuts)] ;   (vim.keymap.del :n s)
        (vim.keymap.set :n "[1" (make-harpoon (fn [] (harpoon-ui.nav_file 1))))
        (vim.keymap.set :n "[2" (make-harpoon (fn [] (harpoon-ui.nav_file 2))))
        (vim.keymap.set :n "[3" (make-harpoon (fn [] (harpoon-ui.nav_file 3))))
        (vim.keymap.set :n "[4" (make-harpoon (fn [] (harpoon-ui.nav_file 4))))
        (vim.keymap.set :n "[5" (make-harpoon (fn [] (harpoon-ui.nav_file 5))))
        (set use-numbers false))))

(vim.api.nvim_create_user_command :H toggle-harpoon-mappings {})
(toggle-harpoon-mappings)
