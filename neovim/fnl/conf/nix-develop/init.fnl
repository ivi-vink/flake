(local loop vim.loop)

(var original-env {})
(local ignored-variables {:SHELL true
                          :BASHOPTS true
                          :HOME true
                          :NIX_BUILD_TOP true
                          :NIX_ENFORCE_PURITY true
                          :NIX_LOG_FD true
                          :NIX_REMOTE true
                          :PPID true
                          :SHELL true
                          :SHELLOPTS true
                          :SSL_CERT_FILE true
                          :TEMP true
                          :TEMPDIR true
                          :TERM true
                          :TMP true
                          :TMPDIR true
                          :TZ true
                          :UID true})

(local separated-dirs {:PATH ":" :XDG_DATA_DIRS ":"})

(fn set-env [key value]
  (if (not (. original-env key))
      (tset original-env key (or (. vim.env key) :nix-develop-nil)))
  (local sep (. separated-dirs key))
  (if sep
      (do
        (local suffix (or (. vim.env key) ""))
        (tset vim.env key (.. value sep suffix)))
      (tset vim.env key value)))

(fn unload-env []
  (each [k v (pairs original-env)]
    (if (= v :nix-develop-nil)
        (tset vim.env k nil)
        (tset vim.env k v))))

(fn ignored? [key]
  (. ignored-variables (string.upper key)))

(fn exported? [Type]
  (= Type :exported))

(fn handle-shellhook [shellhook] ; (P :handle-shellhook shellhook)
  (var shellhook-env "")
  (local stdin (loop.new_pipe))
  (local stdout (loop.new_pipe))
  (local p
         (loop.spawn :bash {:stdio [stdin stdout nil]}
                     (fn [code signal]
                       (vim.schedule #(vim.notify (.. "shellhook: exit code "
                                                      code " " signal))))))
  (loop.read_start stdout
                   (fn [err data]
                     (assert (not err) err)
                     (if data
                         (set shellhook-env (.. shellhook-env data))
                         (do
                           (if (not= shellhook-env "")
                               (vim.schedule (fn []
                                               (local json
                                                      (vim.fn.json_decode shellhook-env))
                                               ; (P json)
                                               (each [key value (pairs json)]
                                                 (set-env key value)))))))))
  (stdin:write (.. shellhook "jq -n 'env'\n\n"))
  (stdin:close))

(fn handle-nix-print-dev-env [str]
  (vim.schedule (fn []
                  (local json (. (vim.fn.json_decode str) :variables))
                  (-> (icollect [key {: type : value} (pairs json)]
                        (do
                          (if (and (exported? type) (not (ignored? key)))
                              (set-env key value))
                          (if (= key :shellHook)
                              value)))
                      (#(each [_ shellhook (ipairs $1)]
                          (handle-shellhook shellhook)))))))

(fn nix-develop [fargs unload]
  (if unload
      (unload-env))
  (local cmd :nix)
  (local fargs (or fargs []))
  (local args [:print-dev-env :--json (unpack fargs)])
  (local stdout (loop.new_pipe))
  (local stdio [nil stdout nil])
  (var nix-print-dev-env "")
  (local p
         (loop.spawn cmd {: args : stdio}
                     (fn [code signal]
                       (if (not= code 0)
                           (vim.schedule #(vim.notify (.. "nix-develop: exit code "
                                                          code " " signal)))))))
  (loop.read_start stdout
                   (fn [err data]
                     (assert (not err) err)
                     (if data
                         (set nix-print-dev-env (.. nix-print-dev-env data))
                         (do
                           (vim.schedule #(vim.notify "nix-develop: stdout end"))
                           (if (not= nix-print-dev-env "")
                               (handle-nix-print-dev-env nix-print-dev-env)))))))

(vim.api.nvim_create_user_command :NixDevelop
                                  (fn [ctx]
                                    (nix-develop ctx.fargs true))
                                  {:nargs "*"})

(vim.api.nvim_create_augroup :nix-develop {:clear true})
(vim.api.nvim_create_autocmd [:DirChanged :VimEnter]
                             {:pattern ["*"]
                              :callback (fn [ctx]
                                          (unload-env)
                                          (if (= 1
                                                 (vim.fn.filereadable (.. ctx.file
                                                                          :/flake.nix)))
                                              (nix-develop false)))})
