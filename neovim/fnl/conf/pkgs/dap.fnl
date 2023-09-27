(local dap (require :dap))
(local adapters (. dap :adapters))
(local configurations (. dap :configurations))

(local dapui (require :dapui))

(tset adapters :delve
      {:type :server
       :port "${port}"
       :executable {:command :dlv :args [:dap :-l "127.0.0.1:${port}"]}})

(tset configurations :go
      [{:type :delve
        :name :Debug
        :request :launch
        :env {:CGO_CFLAGS :-Wno-error=cpp}
        :program "${file}"}
       {:type :delve
        :name :DebugTest
        :request :launch
        :mode :test
        :env {:CGO_CFLAGS :-Wno-error=cpp}
        :program "${file}"}
       {:type :delve
        :name :DebugTerraform
        :request :launch
        :program "${file}"
        :env {:CGO_CFLAGS :-Wno-error=cpp}
        :args [:-debug]}
       {:type :delve
        :name :DebugTerraformAcc
        :request :launch
        :program "${file}"
        :mode :test
        :env {:CGO_CFLAGS :-Wno-error=cpp :TF_ACC :1}}
       {:type :delve
        :name :DebugTestSuite
        :request :launch
        :mode :test
        :env {:CGO_CFLAGS :-Wno-error=cpp}
        :program "${fileDirname}"}])

(dapui.setup {:expand_lines false})

(vim.keymap.set :n :si (lambda []
                         (dapui.toggle {:reset true})) {:silent true})
;;     "breakpoints",
;;     "repl",
;;     "scopes",
;;     "stacks",
;;     "watches",
;;     "hover",
;;     "console",)
(vim.keymap.set :n :sfw
                (lambda []
                  (dapui.float_element :watches
                                       {:width (vim.api.nvim_win_get_width 0) :height 30 :enter true})))
(vim.keymap.set :n :sfs
                (lambda []
                  (dapui.float_element :scopes
                                       {:width (vim.api.nvim_win_get_width 0) :height 30 :enter true})))

(vim.keymap.set :n :sq dap.terminate {:silent true})
(vim.keymap.set :n :sc dap.continue {:silent true})
(vim.keymap.set :n :sr dap.run_to_cursor {:silent true})
(vim.keymap.set :n :sn dap.step_over {:silent true})
(vim.keymap.set :n :ss dap.step_into {:silent true})
(vim.keymap.set :n :so dap.step_out {:silent true})
(vim.keymap.set :n :sb dap.toggle_breakpoint {:silent true})
(vim.keymap.set :n :sB dap.set_breakpoint {:silent true})
(vim.keymap.set :n :slp
                (fn []
                  (dap.set_breakpoint nil nil
                                      (vim.fn.input "Log point message: ")))
                {:silent true})

(vim.keymap.set :n :st dap.repl.toggle {:silent true})
(vim.keymap.set :n :sl dap.run_last {:silent true})
