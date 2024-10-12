(local lspconfig (require :lspconfig))
(local configs (require :lspconfig.configs))

(lspconfig.nil_ls.setup {})

(lspconfig.rust_analyzer.setup
  {:autostart false
   :settings
   {:rust-analyzer
    {:cargo {:buildScripts {:enable true}}
     :procMacro {:enable true :attributes {:enable true}}
     :inlayHints {:enable true}}}
   :root_dir
   (lspconfig.util.root_pattern
     :.git
     (vim.fn.getcwd))})

(lspconfig.pyright.setup
  {:root_dir
   (lspconfig.util.root_pattern
     :.git
     (vim.fn.getcwd))
   :settings
   {:venvPath (.. (vim.fn.getcwd) :.venv)}})

(lspconfig.ts_ls.setup
  {:root_dir
   (lspconfig.util.root_pattern
     :.git
     (vim.fn.getcwd))})

(lspconfig.gopls.setup
  {:root_dir (lspconfig.util.root_pattern :.git
                                          (vim.fn.getcwd))
   :settings {:gopls {:codelenses {:test true :bench true}
                      ;;  Show a code lens toggling the display of gc's choices.}
                      :buildFlags [:-tags=all]}}})

(lspconfig.ansiblels.setup
  {:ansible {:ansible {:path :ansible}
             :executionEnvironment {:enabled false}
             :python {:interpreterPath :python}
             :validation {:enabled true
                          :lint {:enabled false
                                 :arguments " --profile=production --write=all "
                                 :path :ansible-lint}}}})
