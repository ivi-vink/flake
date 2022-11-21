;; Ahead of time compiles this file to ./init.lua
(fn build-init []
  (let [{: build} (require :hotpot.api.make)
        allowed-globals (icollect [n _ (pairs _G)] n)
        opts {:verbosity 0
              :compiler {:modules {:allowedGlobals allowed-globals}}}]
    (build "/home/mike/dotnix/neovim/init.fnl" opts ".+" #(values $1))))

;; Call hotpot.setup and compile again after fs event 
(let [hotpot (require :hotpot)
      setup hotpot.setup
      build hotpot.api.make.build
      uv vim.loop]

  (setup {:provide_require_fennel true
          :compiler {:modules {:correlate true}
                     :macros {:env :_COMPILER
                              :compilerEnv _G
                              :allowedGlobals false}}})

  (let [handle (uv.new_fs_event)
        path (vim.fn.expand "/home/mike/dotnix/neovim/init.fnl")]
    (uv.fs_event_start handle path {} #(vim.schedule build-init))
    (vim.api.nvim_create_autocmd :VimLeavePre {:callback #(uv.close handle)})))

(require :conf)
