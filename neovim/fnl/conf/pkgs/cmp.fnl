(local cmp (require :cmp))
(local compare (require :cmp.config.compare))
(local always-first [:write :edit :split :quit :cfirst])

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
    (if (not autocomplete) (tset cfg :completion {:autocomplete false}))
    ;; (print (vim.inspect cfg))
    (cmp.setup cfg)
    (cmp.setup.cmdline ["/" "?"]
                       {:sources (cmp.config.sources [{:name :buffer}])
                        :experimental {:ghost_text true}
                        :mapping (cmp.mapping.preset.cmdline)})
    (cmp.setup.cmdline ":"
                       {:matching {:disallow_partial_fuzzy_matching true
                                   :disallow_prefix_unmatching true}
                        :sources (cmp.config.sources [{:name :path}]
                                                     [{:name :cmdline
                                                       :keyword_length 1}])
                        :preselect cmp.PreselectMode.Item
                        :sorting {:priority_weight 2
                                  :comparators [(fn [e1 e2]
                                                  (fn iter [[item & rest]]
                                                    (if (or (not rest)
                                                            (not item))
                                                        false
                                                        (= e1.completion_item.label
                                                           item)
                                                        true
                                                        (iter rest)))

                                                  (iter always-first))
                                                compare.offset
                                                compare.exact
                                                compare.score
                                                compare.locality
                                                compare.kind
                                                compare.length
                                                compare.order]}
                        :mapping (cmp.mapping.preset.cmdline {:<CR> {:c (fn [fallback]
                                                                          (if (not (cmp.confirm {:behavior (enum :ConfirmBehavior
                                                                                                                 :Replace)
                                                                                                 :select true}))
                                                                              (fallback)
                                                                              (vim.schedule fallback)))}})})))

; {:name :cmdline_history
;                                                        :keyword_pattern "^[ABCDEFHIJKLMNOPQRSTUVWXYZ].*"
;                                                        :entry_filter (fn [entry
;                                                                           ctx]
;                                                                        (if (string-startswith-upper entry.completion_item.label)
;                                                                            true
;                                                                            false))
;                                                        :max_item_count 1)})))
;     disallow_fuzzy_matching = false,
;     disallow_partial_matching = false,
;     disallow_prefix_unmatching = false,)))
(cmp-setup cmp true)
