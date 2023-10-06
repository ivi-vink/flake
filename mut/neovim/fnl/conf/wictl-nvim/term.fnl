(tset package.loaded :conf.wict-nvim nil)
(local ui (require :conf.wict-nvim))
(tset package.loaded :conf.wict-nvim.effects nil)
(local ui-eff (require :conf.wict-nvim.effects))

(tset package.loaded :conf.wictl-nvim nil)
(local wictl (require :conf.wictl-nvim))

(local Resolver (require :conf.wictl-nvim.resolvers))
(local ui-bld ui.builder)
(local M {})

(local ProjectBufs {})
(var selected nil)
(local term-ui (-> (ui-bld.For {:buffer (fn [] selected)
                                :maps [{:mode [:n :v :o]
                                        :lhs :q
                                        :rhs (fn [effects window]
                                               (fn []
                                                 (P :quitting!)
                                                 (effects:close)))}]})
                   (ui-bld.Padding 2)
                   (ui-bld.Build (ui-eff:new))))

(fn M.open [idx]
  (local new-term-buf (fn []
                        (local (buf_handle term_handle) (M.start idx))
                        (tset ProjectBufs (Resolver.project_key) idx
                              {: buf_handle : term_handle})
                        {: buf_handle : term_handle}))
  (local proj (or (. ProjectBufs (Resolver.project_key))
                  (do
                    (local p [])
                    (tset ProjectBufs (Resolver.project_key) p)
                    p)))
  (var term (or (. proj idx) (new-term-buf)))
  (if (or (not (vim.api.nvim_buf_is_valid term.buf_handle))
          (not (vim.api.nvim_buf_get_var term.buf_handle :terminal_job_id)))
      (set term (new-term-buf)))
  (set selected term.buf_handle)
  (term-ui ui.root-frame))

(fn M.start [idx]
  (P :starting)
  (local term (. (wictl.Get-Terms-Config) idx))
  (local prestart-buf (vim.api.nvim_get_current_buf))
  (vim.cmd (.. "edit term://" term.cmd))
  (local buf_handle (vim.api.nvim_get_current_buf))
  (local term_handle vim.b.terminal_job_id)
  (vim.api.nvim_buf_set_option buf_handle :bufhidden :hide)
  (vim.api.nvim_set_current_buf prestart-buf)
  (values buf_handle term_handle))

M
