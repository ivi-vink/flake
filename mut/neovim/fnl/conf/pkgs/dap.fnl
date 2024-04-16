(local dap (require :dap))
(local adapters (. dap :adapters))
(local configurations (. dap :configurations))

(local dapui (require :dapui))
(local dap-py (require :dap-python))

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

(set dap.defaults.fallback.external_terminal
  {:command :/Applications/Alacritty.app/Contents/MacOS/alacritty
   :args [:-T :dap :-e]});


(dapui.setup
  {:expand_lines false
   :layouts
   [{:position :bottom :size 10 :elements [{:id :repl :size 0.5} {:id :console :size 0.5}]}
    {:position :left :size 40 :elements [{:id :breakpoints :size 0.25} {:id :stacks :size 0.25} {:id :watches :size 0.25} {:id :scopes :size 0.25}]}
    {:position :bottom :size 25 :elements [{:id :repl :size 0.35} {:id :watches :size 0.65}]}]})
(dap-py.setup nil {:console :externalTerminal})
(tset (. configurations.python 1) :waitOnNormalExit true)
(tset (. configurations.python 1) :waitOnAbnormalExit true)

(local run_table
       {:python
        (fn [fname]
          {
           :name (.. "Launch " fname)
           :program fname
           :console "externalTerminal"
           :request "launch"
           :type "python"
           :waitOnAbnormalExit true
           :waitOnNormalExit true})})

(vim.keymap.set
  :n
  "s;"
  (fn []
    (local fname (vim.fn.fnamemodify (vim.fn.bufname "%") ":p"))
    (local get_config (. run_table (vim.opt_local.ft:get)))
    (if get_config
      (dap.run (get_config fname)))))


(vim.keymap.set :n :si (lambda []
                         (dapui.toggle {:layout 1 :reset true})
                         (dapui.toggle {:layout 2 :reset true})) {:silent true})
(vim.keymap.set :n :s<enter> #(dapui.toggle {:layout 3 :reset true}) {:silent true})
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
