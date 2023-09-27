(local lspconfig (require :lspconfig))
(local configs (require :lspconfig.configs))
(local {: attach} (require :conf.lsp))

(lspconfig.pyright.setup {:root_dir (lspconfig.util.root_pattern :.git
                                                                 (vim.fn.getcwd))
                          :on_attach attach})

(lspconfig.tsserver.setup {:root_dir (lspconfig.util.root_pattern :.git
                                                                  (vim.fn.getcwd))
                           :on_attach attach})

(local pid (vim.fn.getpid))
(lspconfig.omnisharp.setup {:cmd [:OmniSharp
                                  :--languageserver
                                  :--hostPID
                                  (tostring pid)]
                            :handlers {[:textDocument/definition] (. (require :omnisharp_extended)
                                                                     :handler)}
                            :root_dir (lspconfig.util.root_pattern :.git
                                                                   (vim.fn.getcwd))
                            :on_attach attach})

(lspconfig.gopls.setup {:root_dir (lspconfig.util.root_pattern :.git
                                                               (vim.fn.getcwd))
                        :on_attach attach
                        :settings {:gopls {:codelenses {:test true :bench true}
                                           ;;  Show a code lens toggling the display of gc's choices.}
                                           :buildFlags [:-tags=all]}}})

(lspconfig.ansiblels.setup {:ansible {:ansible {:path :ansible}
                                      :executionEnvironment {:enabled false}
                                      :python {:interpreterPath :python}
                                      :validation {:enabled true
                                                   :lint {:enabled false
                                                          :arguments " --profile=production --write=all "
                                                          :path :ansible-lint}}}})

;; (tset configs :fennel_language_server
;;       {:default_config {;; replace it with true path
;;                         :cmd [:fennel-language-server]
;;                         :filetypes [:fennel]
;;                         :single_file_support true
;;                         ;; source code resides in directory `fnl/`
;;                         :root_dir (lspconfig.util.root_pattern :fnl)
;;                         :settings {:fennel {:workspace {;; If you are using hotpot.nvim or aniseed,
;;                                                         ;; make the server aware of neovim runtime files.
;;                                                         :library (vim.api.nvim_list_runtime_paths)}
;;                                             :diagnostics {:globals [:vim]}}}}})
;;
;; (lspconfig.fennel_language_server.setup {:on_attach attach})
