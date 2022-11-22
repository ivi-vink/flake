(fn map-to-capabilities [{: client : buf}]
  (fn bufoption [name value]
    (vim.api.nvim_buf_set_option buf name value))

  (fn bufmap [mode key cb]
    (vim.keymap.set mode key cb {:silent true :noremap true :buffer buf}))

  (fn lspdo [action]
    (. vim.lsp action))

  (fn use [cpb]
    (match cpb
      :completion (bufoption :omnifunc "v:lua.vim.lsp.omnifunc")
      :rename (bufmap :n :<leader>gr (lspdo :rename))
      :signature_help (bufmap :n :<leader>gs (lspdo :signature_help))
      :goto_definition (bufmap :n :<leader>gd (lspdo :definition))
      :declaration (bufmap :n :<leader>gD (lspdo :declaration))
      :implementation (bufmap :n :<leader>gi (lspdo :implementation))
      :find_references (bufmap :n :<leader>gi (lspdo :references))
      :document_symbol (bufmap :n :<leader>gds (lspdo :workspace_symbol))
      :code_action (bufmap :n :<leader>ga (lspdo :code_action))
      :document_range_formatting (bufmap :v :<leader>gq
                                         (lspdo :range_formatting))
      :hover (bufoption :keywordprg ":LspHover")
      :documentFormattingProvider ((fn []
                                     (bufoption :formatexpr
                                              "v:lua.vim.lsp.format()")
                                     (bufmap :n :<leader>gq
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
