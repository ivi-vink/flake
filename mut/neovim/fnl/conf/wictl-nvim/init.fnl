(local Path (require :plenary.path))
(tset package.loaded :conf.wict-nvim nil)
(local wict (require :conf.wict-nvim))
(tset package.loaded :conf.wictl-nvim.resolvers nil)
(local Resolver (require :conf.wictl-nvim.resolvers))

(local bld wict.builder)
(local eff wict.effects)

(local config_path (vim.fn.stdpath :config))
(local data_path (vim.fn.stdpath :data))
(local user_config (string.format "%s/wictl.json" config_path))
(local cache_config (string.format "%s/wictl.json" data_path))

(local m {})

(local WictlConfig {})
;; {
;;   ["/path/to/project"] = {
;;      terms = [{cmd = "k9s"}]
;; }

(fn m.Edit [project])

(fn m.Read [path]
  (local p (Path:new path))
  (vim.fn.json_decode (p:read)))

(fn m.Save []
  (local cache-path (Path:new cache_config))
  (cache-path:write (vim.fn.json_encode WictlConfig) :w))

(local ensure-complete-project (fn [config]
                                 (var config (or config {:terms []}))
                                 (if (not config.terms)
                                     (set config.terms
                                          [{:name :k9s :cmd :bash}]))
                                 config))

(local get-project (fn []
                     (local proj (. WictlConfig (Resolver.project_key)))
                     (ensure-complete-project (or proj
                                                  (do
                                                    (local cfg {})
                                                    (tset WictlConfig
                                                          (Resolver.project_key)
                                                          cfg)
                                                    cfg)))))

(fn m.Get-Terms-Config []
  (local proj (get-project))
  proj.terms)

(m.Save)
(m.Read cache_config)
(m.Get-Terms-Config)

m
