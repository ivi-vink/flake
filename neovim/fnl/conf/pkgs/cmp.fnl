(let [cmp (require :cmp)
      luasnip (require :luasnip)
      snip (fn [args]
             (luasnip.lsp_expand (. args :body)))]
  (cmp.setup {:snippet {:expand snip}
              :completion {:autocomplete false}
              :mapping (cmp.mapping.preset.insert {:<C-b> (cmp.mapping.scroll_docs -4)
                                                   :<C-f> (cmp.mapping.scroll_docs 4)
                                                   :<C-A> (cmp.mapping.complete)
                                                   :<C-e> (cmp.mapping.confirm {:select true})})
              :sources (cmp.config.sources [{:name :conjure}
                                            {:name :nvim_lsp}
                                            {:name :path}
                                            {:name :luasnip}])}))
