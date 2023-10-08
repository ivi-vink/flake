(local cmp (require :cmp))

(fn has-words-before? []
  (local [line col] (vim.api.nvim_win_get_cursor 0))
  (local [word & rest] (vim.api.nvim_buf_get_lines 0 (- line 1) line true))
  (local before (word:sub col col))
  (local is_string (before:match "%s"))
  (and (not= col 0) (= is_string nil)))

(fn edit? [line]
  (not= nil (line:match "^ed?i?t? .*$")))

(fn enum [types key]
  (. (. cmp types) key))

(fn cmp-setup [cmp autocomplete]
  (let [luasnip (require :luasnip)
        snip (fn [args]
               (luasnip.lsp_expand (. args :body)))]
    (local cfg
           {:experimental {:ghost_text true}
            :snippet {:expand snip}
            :preselect cmp.PreselectMode.None
            :mapping {:<Tab> (cmp.mapping (fn [fallback]
                                            (if (cmp.visible)
                                                (cmp.select_next_item)
                                                (luasnip.expand_or_jumpable)
                                                (luasnip.expand_or_jump)
                                                (has-words-before?)
                                                (cmp.complete)
                                                (fallback))
                                            [:i :s]))
                      :<S-Tab> (cmp.mapping (fn [fallback]
                                              (if (cmp.visible)
                                                  (cmp.select_prev_item)
                                                  (luasnip.jumpable -1)
                                                  (luasnip.jump -1)
                                                  (fallback))
                                              [:i :s]))
                      :<C-b> (cmp.mapping.scroll_docs -4)
                      :<C-f> (cmp.mapping.scroll_docs 4)
                      :<C-j> (cmp.mapping.complete)
                      :<CR> (cmp.mapping.confirm {:behavior (enum :ConfirmBehavior
                                                                  :Replace)
                                                  :select true})}
            :sources (cmp.config.sources [{:name :nvim_lsp}
                                          {:name :path}
                                          {:name :luasnip}])})

    ; This tries to emulate somewhat ido mode to find files
    ; todo sorting based on least recently used
   (cmp.setup.cmdline
     ":"
      {:enabled (fn [] (local val (edit? (vim.fn.getcmdline)))
                       (if (not val)
                           (cmp.close))
                       val)
       :completion {:completeopt "menu,menuone,noinsert"}
       :mapping {:<CR> (cmp.mapping
                         (fn [fallback]
                           (local entry (cmp.get_selected_entry))
                           (local line (vim.fn.getcmdline))
                           (if (or (= nil entry) (not (edit? line)))
                               (do
                                 (vim.schedule fallback))
                               (do
                                 (cmp.confirm {:select true :behavior cmp.ConfirmBehavior.Replace})
                                 (if (entry.completion_item.label:match "%.*/$")
                                     (do
                                       (vim.defer_fn cmp.complete 10))
                                     (do
                                       (vim.schedule fallback))))))
                         [:i :c])}
       :sources (cmp.config.sources
                   [{:name :cmdline} {:name :path}])}



    (if (not autocomplete) (tset cfg :completion {:autocomplete false}))
    ;; (print (vim.inspect cfg))
    (cmp.setup cfg))))

(let [map vim.keymap.set]
  (map :n :<leader>xf (fn []
                        (vim.api.nvim_feedkeys (.. ":e " (vim.fn.getcwd)) :c false)
                        (vim.defer_fn #(vim.api.nvim_feedkeys "/" :c false) 10))))

(cmp-setup (require :cmp) true)
