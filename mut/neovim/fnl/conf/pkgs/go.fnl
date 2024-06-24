(local go (require :go))
(go.setup
  {
   :goimports false
   :fillstruct false
   :gofmt false
   :max_line_len nil
   :tag_transform false
   :test_dir false
   :comment_placeholder "   "
   :icons false
   :verbose false
   :log_path (.. (vim.fn.expand "$HOME") "/tmp/gonvim.log")
   :lsp_cfg false
   :lsp_gofumpt false
   :lsp_on_attach nil
   :lsp_keymaps false
   :lsp_codelens false
   :diagnostic false
   :lsp_inlay_hints {:enable false}
   :gopls_remote_auto false
   :gocoverage_sign "█"
   :sign_priority 7
   :dap_debug false
   :dap_debug_gui false
   :dap_debug_keymap false
   :dap_vt false
   :textobjects false
   :gopls_cmd nil
   :build_tags ""
   :test_runner "go"
   :run_in_floaterm false
   :luasnip true
   :iferr_vertical_shift 4})

