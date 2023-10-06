(tset vim.g "conjure#log#wrap" true)

(tset vim.g "conjure#client#python#stdio#command" "python -iq")

(vim.api.nvim_create_user_command :ConjurePythonCommand
                                  (fn [opts]
                                    (tset vim.g
                                          "conjure#client#python#stdio#command"
                                          opts.args))
                                  {:nargs 1})

(let [group (vim.api.nvim_create_augroup "conf#pkgs#conjure" {:clear true})]
  (vim.api.nvim_create_autocmd [:BufEnter]
                               {: group
                                :callback (fn [opts]
                                            (vim.diagnostic.disable opts.buf))
                                :pattern [:conjure-log*]}))
