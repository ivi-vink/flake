;; fixes nixpkgs hotpot not adding package path correctly

(tset _G.package :path
      (.. (vim.fn.stdpath :cache) "/hotpot/hotpot.nvim/lua/?/init.lua;"
          package.path))

(fn build-init []
  (let [{: build} (require :hotpot.api.make)
        allowed-globals (icollect [n _ (pairs _G)]
                          n)
        opts {:verbosity 0
              :compiler {:modules {:allowedGlobals allowed-globals}}}
        here #(values $1)
        config-path (vim.fn.stdpath :config)]
    (build config-path opts (.. config-path :/init.fnl) here
           (.. config-path :/after/ftdetect/.+) here
           (.. config-path :/ftplugin/.+) here
           (.. config-path :/after/ftplugin/.+) here)))

;; Call hotpot.setup and compile again after fs event

(let [hotpot (require :hotpot)
      setup hotpot.setup
      build hotpot.api.make.build
      uv vim.loop
      config-path (vim.fn.stdpath :config)]
  (setup {:provide_require_fennel true
          :compiler {:modules {:correlate true}
                     :macros {:env :_COMPILER
                              :compilerEnv _G
                              :allowedGlobals false}}})
  (let [handle (uv.new_fs_event)
        path (vim.fn.expand (.. config-path :/init.fnl))]
    (uv.fs_event_start handle path {} #(vim.schedule build-init))
    (vim.api.nvim_create_autocmd :VimLeavePre {:callback #(uv.close handle)})))
(require :conf)
