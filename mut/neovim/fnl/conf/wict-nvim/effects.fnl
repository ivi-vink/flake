(local m {})
(local window {})

(local aug vim.api.nvim_create_augroup)
(local del-aug (fn [] (vim.api.nvim_create_augroup :EffectsMgr {:clear true})))
(local au vim.api.nvim_create_autocmd)
(local winvar (fn [...] (pcall vim.api.nvim_win_get_var ...)))
(local unmap (fn [{: mode : lhs : opts}] (pcall vim.keymap.del mode lhs opts)))
(local map (fn [mode lhs rhs opts] (vim.keymap.set mode lhs rhs opts)))

(fn window.close [self]
  (if (self:open?)
      (set self.handle (vim.api.nvim_win_close self.handle true))))

(fn window.open [self buf frame]
  (set frame.style :minimal)
  (set self.handle (vim.api.nvim_open_win buf false frame))
  (P self.handle :before-setvar)
  (vim.api.nvim_buf_set_var buf :effect-window self)
  (vim.api.nvim_win_set_var self.handle :effect-window self)
  (if self.enter
      (vim.api.nvim_set_current_win self.handle)))

(fn window.id [self]
  self.handle)

(fn window.open? [self]
  (if self.handle
      (vim.api.nvim_win_is_valid self.handle) false))

(fn window.new [self i enter maps]
  (local w (setmetatable {: i : enter : maps} window))
  (set self.__index self)
  w)

(fn m.new-window [self maps]
  (local w (window:new (+ (length self.windows) 1) (= (length self.windows) 0)
                       maps))
  (table.insert self.windows w)
  w)

(fn m.close [self]
  (each [_ w (ipairs self.windows)]
    (w:close))
  (if self.augroup
      (set self.augroup (del-aug self.augroup)))
  (if self.unmap
      (set self.unmap (self.unmap))))

(fn m.attach [self]
  (set self.augroup (aug :EffectsMgr {:clear true}))
  (au [:WinEnter]
      {:group self.augroup
       :pattern "*"
       :callback (fn [cb-info]
                   (P :effectEnter)
                   (local (ok? win) (winvar 0 :effect-window))
                   (P ok? win)
                   (if (not ok?)
                       (self:close)
                       (do
                         (if win.maps
                             (self:win-maps win)))))}))

(fn m.win-maps [self win]
  (P win)
  (if self.unmap
      (self.unmap))
  (set self.unmap (fn []
                    (each [_ m (ipairs win.maps)]
                      (unmap m))))
  (each [_ {: mode : lhs : rhs : opts} (ipairs win.maps)]
    (map mode lhs (rhs self win) opts)))

(fn m.new [self opts]
  (local effects {:windows []})
  (setmetatable effects self)
  (set self.__index self)
  effects)

m
