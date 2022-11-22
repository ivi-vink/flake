(fn reload [mod]
  (fn loaded? [mod]
    (not= (. package.loaded mod) nil))

  (fn unload [mod]
    (tset package.loaded mod nil))

  (if (loaded? mod) (unload mod))
  (require mod))

(let [null-ls (require :null-ls)]
  (null-ls.setup {:update_on_insert false
                  :on_attach (. (reload :conf.lsp) :attach)
                  :sources [null-ls.builtins.formatting.black
                            null-ls.builtins.formatting.raco_fmt
                            null-ls.builtins.formatting.alejandra
                            null-ls.builtins.formatting.fnlfmt]}))
