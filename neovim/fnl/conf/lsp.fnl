(fn map-to-capabilities [{: client : buf} format]
  (fn bo [name value]
    (vim.api.nvim_buf_set_option buf name value))

  (fn bm [mode key cb]
    (vim.keymap.set mode key cb {:silent true :noremap true :buffer buf}))

  (fn lspdo [action]
    (. vim.lsp.buf action))

  (fn use [cpb]
    (match cpb
      :completionProvider (bo :omnifunc "v:lua.vim.lsp.omnifunc")
      :renameProvider (bm :n :<leader>gr (lspdo :rename))
      :signatureHelpProvider (bm :n :<leader>gs (lspdo :signature_help))
      :definitionProvider (bm :n :<leader>gd (lspdo :definition))
      :declaration (bm :n :<leader>gD (lspdo :declaration))
      :implementationProvider (bm :n :<leader>gi (lspdo :implementation))
      :referencesProvider (bm :n :<leader>gg (lspdo :references))
      :documentSymbolProvider (bm :n :<leader>gds (lspdo :workspace_symbol))
      :codeActionProvider (bm :n :<leader>ga (lspdo :code_action))
      :codeLensProvider (bm :n :<leader>gl
                            (lambda []
                              (vim.lsp.codelens.run)))
      :hoverProvider (bo :keywordprg ":LspHover")
      :documentFormattingProvider (if format
                                      ((fn []
                                         (bo :formatexpr
                                             "v:lua.vim.lsp.format()")
                                         (bm :n :<leader>gq
                                             #(vim.lsp.buf.format {:async true})))))))

  (each [cpb enabled? (pairs client.server_capabilities)]
    (if enabled?
        (use cpb)))
  {: client : buf})

(fn register-handlers [{: client : buf}]
  (tset (. client :handlers) :textDocument/publishDiagnostics
        (vim.lsp.with (fn [_ result ctx config]
                        (vim.lsp.diagnostic.on_publish_diagnostics _ result ctx
                                                                   config)
                        (vim.diagnostic.setloclist {:open false}))
          {:virtual_text true
           :underline true
           :update_in_insert false
           :severity_sort true}))
  {: client : buf})

(var format-on-save true)
(fn toggle-format-on-save []
  (set format-on-save (not format-on-save)))

(vim.api.nvim_create_user_command :LspToggleOnSave toggle-format-on-save
                                  {:nargs 1 :complete (fn [] [:format])})

(fn events [{: client : buf}]
  (match client.server_capabilities
    {:documentFormattingProvider true}
    (let [format-events-group (vim.api.nvim_create_augroup :format-events
                                                           {:clear true})]
      (vim.api.nvim_create_autocmd [:BufWritePre]
                                   {:group format-events-group
                                    :callback (lambda []
                                                (if format-on-save
                                                    (vim.lsp.buf.format)))
                                    :buffer buf}))))

(fn attach [client buf format]
  (-> {: client : buf}
      (register-handlers)
      (map-to-capabilities format)
      (events)))

{: attach}
