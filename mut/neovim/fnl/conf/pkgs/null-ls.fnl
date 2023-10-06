(local lsp-conf (require :conf.lsp))
(local null-ls (require :null-ls))

(local fmt null-ls.builtins.formatting)
(local diag null-ls.builtins.diagnostics)

(fn executable? [program]
  (fn []
    (= 1 (vim.fn.executable program))))

(null-ls.setup {:update_in_insert false
                :debug true
                :on_attach (fn [client buf]
                             (lsp-conf.attach client buf true))
                :sources [fmt.alejandra
                          fmt.fnlfmt
                          (fmt.black.with {:condition (executable? :black)})
                          (fmt.goimports.with {:condition (executable? :goimports)})
                          (fmt.gofumpt.with {:condition (executable? :gofumpt)})
                          (fmt.raco_fmt.with {:condition (executable? :raco)})
                          (fmt.terraform_fmt.with {:condition (executable? :terraform)})]})
