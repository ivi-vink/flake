(fn map-to-capabilities [{: client : buf}]
  (fn bo [name value]
    (vim.api.nvim_buf_set_option buf name value))

  (fn bm [mode key cb]
    (vim.keymap.set mode key cb {:silent true :noremap true :buffer buf}))

  (fn lspdo [action]
    (. vim.lsp action))

  (fn use [cpb]
    (match cpb
      :completion (bo :omnifunc "v:lua.vim.lsp.omnifunc")
      :rename (bm :n :<leader>gr (lspdo :rename))
      :signature_help (bm :n :<leader>gs (lspdo :signature_help))
      :goto_definition (bm :n :<leader>gd (lspdo :definition))
      :declaration (bm :n :<leader>gD (lspdo :declaration))
      :implementation (bm :n :<leader>gi (lspdo :implementation))
      :find_references (bm :n :<leader>gi (lspdo :references))
      :document_symbol (bm :n :<leader>gds (lspdo :workspace_symbol))
      :code_action (bm :n :<leader>ga (lspdo :code_action))
      :document_range_formatting (bm :v :<leader>gq (lspdo :range_formatting))
      :hover (bo :keywordprg ":LspHover")
      :documentFormattingProvider ((fn []
                                     (bo :formatexpr "v:lua.vim.lsp.format()")
                                     (bm :n :<leader>gq
                                         #(vim.lsp.buf.format {:async true}))))))

  (each [cpb enabled? (pairs client.server_capabilities)]
    (if enabled?
        (use cpb))))

(fn attach [client buf]
  (fn P [p]
    (print (vim.inspect p))
    p)

  (-> {: client : buf}
      (map-to-capabilities)))

{: attach}
