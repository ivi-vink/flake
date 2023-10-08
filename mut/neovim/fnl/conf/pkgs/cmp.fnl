(local cmp (require :cmp))

(fn string-startswith? [str start]
  (= start (string.sub str 1 (string.len start))))

(fn string-startswith-anyof? [str start-list]
  (fn iter [[item & rest]]
    (if (not item) false
        (string-startswith? str item) true
        (iter rest)))

  (iter start-list))

(fn string-startswith-upper? [str]
  (local first-char (string.sub str 1 1))
  (= first-char (string.upper first-char)))

(fn has-words-before? []
  (local [line col] (vim.api.nvim_win_get_cursor 0))
  (local [word & rest] (vim.api.nvim_buf_get_lines 0 (- line 1) line true))
  (local before (word:sub col col))
  (local is_string (before:match "%s"))
  (and (not= col 0) (= is_string nil)))


(fn edit? []
  (local line (vim.fn.getcmdline))
  (not= nil (line:match "ed?i?t? %.*")))


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
    ; todo sorting based on least recently used
   (cmp.setup.cmdline
     ":"
      {:completion {:completeopt "menu,menuone,noinsert"}
       :matching {:disallow_fuzzy_matching false
                  :disallow_fullfuzzy_matching false
                  :disallow_partial_fuzzy_matching false
                  :disallow_partial_matching false
                  :disallow_prefix_unmatching false}

       :mapping (cmp.mapping.preset.cmdline {
                                             :<M-CR> (cmp.mapping
                                                       (fn []
                                                         (cmp.confirm {:select true :behavior cmp.ConfirmBehavior.Replace})
                                                         (vim.api.nvim_feedkeys " " :c false)
                                                         (vim.defer_fn cmp.complete 10))
                                                       [:i :c])
                                             :<CR> (cmp.mapping
                                                     (fn [fallback]
                                                       (local entry (cmp.get_selected_entry))
                                                       (if (or (= nil entry) (not (edit?)))
                                                           (vim.schedule fallback)
                                                           (do
                                                             (cmp.confirm {:select true :behavior cmp.ConfirmBehavior.Replace})
                                                             (if (entry.completion_item.label:match "%.*/$")
                                                                 (do
                                                                   (vim.defer_fn cmp.complete 10))
                                                                 (do
                                                                   (vim.schedule fallback))))))
                                                     [:i :c])
                                             :<M-BS> {:c (fn [fallback]
                                                           (if (not (edit?))
                                                               (fallback)
                                                               (do
                                                                 (local line (vim.fn.getcmdline))
                                                                 (local key (vim.api.nvim_replace_termcodes "<C-w>" true false true))
                                                                 (if (= nil (line:match "%.*/$"))
                                                                     (vim.api.nvim_feedkeys key :c false)
                                                                     (do
                                                                       (vim.api.nvim_feedkeys (.. key key) :c false)))
                                                                 (vim.defer_fn #(cmp.complete) 10))))}
                                             :<C-w> {:c (fn [fallback]
                                                          (fallback)
                                                          (vim.defer_fn #(cmp.complete) 10))}
                                             :<C-y> {:c (fn [fallback]
                                                           (cmp.confirm {:select false})
                                                           (vim.defer_fn #(cmp.complete) 10))}})
       :sources (cmp.config.sources
                   [{:name :cmdline} {:name :path}])}



    (if (not autocomplete) (tset cfg :completion {:autocomplete false}))
    ;; (print (vim.inspect cfg))
    (cmp.setup cfg))))

(let [map vim.keymap.set]
  (map :n :<leader>xf (fn []
                        (vim.api.nvim_feedkeys (.. ":e " (vim.fn.getcwd)) :c false)
                        (vim.schedule #(vim.api.nvim_feedkeys "/" :c false)))))

(cmp-setup (require :cmp) true)
