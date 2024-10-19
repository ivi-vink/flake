function set_buf_opt(buf, name, value)
  return function() vim.api.nvim_buf_set_option(buf, name, value) end
end

function buf_map(mode, key, fn)
  return function() vim.keymap.set(mode, key, fn, {silent= true,  noremap = true, buffer = 0}) end
end

function lsp_action(action)
  return vim.lsp.buf[action]
end

local capability_map = {
  -- completionProvider = (set_buf_opt :omnifunc "v:lua.vim.lsp.omnifunc"),
      -- hoverProvider = set_buf_opt("keywordprg", ":LspHover"),
          renameProvider = buf_map("n", "<leader>gr", lsp_action("rename")),
   signatureHelpProvider = buf_map("n", "<leader>gs", lsp_action("signature_help")),
      definitionProvider = buf_map("n", "<leader>gd", lsp_action("definition")),
             declaration = buf_map("n", "<leader>gD", lsp_action("declaration")),
  implementationProvider = buf_map("n", "<leader>gi", lsp_action("implementation")),
      referencesProvider = buf_map("n", "<leader>gg", lsp_action("references")),
  documentSymbolProvider = buf_map("n", "<leader>gds", lsp_action("workspace_symbol")),
      codeActionProvider = buf_map("n", "<leader>ga", lsp_action("code_action")),
        codeLensProvider = buf_map("n", "<leader>gl", vim.lsp.codelens.run),
      inlayHintProvider = function()
        vim.lsp.inlay_hint.enable(true)
        buf_map("n", "<leader>gh", function() vim.lsp.inlay_hint.enable(0, not vim.lsp.inlay_hint.is_enabled(0)) end)
      end,
     documentFormattingProvider = function()
      set_buf_opt("formatexpr", "v:lua.vim.lsp.format()")
      buf_map("n", "<leader>gq", function() vim.lsp.buf.format({async= true}) end)
    end,
}

local M = {}

-- (fn map-to-capabilities [{: client : buf}]
--   (fn use [cpb]
--     (match cpb
--
--  (each [cpb enabled? (pairs client.server_capabilities)]
--    (if enabled?
--        (use cpb)))
--  {: client : buf})

-- (fn register-handlers [{: client : buf}]
--   (tset (. client :handlers) :textDocument/publishDiagnostics
--         (vim.lsp.with
--           (fn [_ result ctx config]
--             (vim.lsp.diagnostic.on_publish_diagnostics _ result ctx
--                                                        config)
--             (vim.diagnostic.setloclist {:open false}))
--           {:virtual_text false
--            :underline true
--            :update_in_insert false
--            :severity_sort true}))
--   {: client : buf})

-- (var format-on-save true)
-- (fn toggle-format-on-save []
--   (set format-on-save (not format-on-save)))
-- (vim.api.nvim_create_user_command :LspToggleOnSave toggle-format-on-save {:nargs 1 :complete (fn [] [:format])})

-- (fn events [{: client : buf}]
--   (match client.server_capabilities
--     {:documentFormattingProvider true}
--     (vim.api.nvim_create_autocmd
--      :BufWritePre
--      {:group
--       (vim.api.nvim_create_augroup :format-events {:clear true})
--       :buffer buf
--       :callback #(if format-on-save (vim.lsp.buf.format))})))

M.attach = function (ev)
  vim.iter(ev.client.server_capabilities)
    :each(function(c)
      local fn = capability_map[c]
      if fn then fn() end
    end)
end

-- (fn attach [cb]
--   (-> cb
--       (register-handlers)
--       (map-to-capabilities)
--       (events)))
-- (fn lsp-attach-event [ev]
--   (local client (vim.lsp.get_client_by_id ev.data.client_id))
--   (local buf ev.buf)
--   (attach {: client : buf}))
 -- {: attach : lsp-attach-event}
return M
