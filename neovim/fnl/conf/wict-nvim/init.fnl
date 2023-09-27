(tset package.loaded :conf.wict-nvim.frames.vec nil)
(local vec (require :conf.wict-nvim.frames.vec))

(tset package.loaded :conf.wict-nvim.frames.frame nil)
(local frame (require :conf.wict-nvim.frames.frame))

(tset package.loaded :conf.wict-nvim.builder nil)
(local builder (require :conf.wict-nvim.builder))

(tset package.loaded :conf.wict-nvim.effects nil)
(local effects (require :conf.wict-nvim.effects))

(local m {})

(local root-frame (frame (vec.vec 0 0) (vec.vec vim.o.columns 0)
                         (vec.vec 0 vim.o.lines)))

(local painter (-> (builder.For {:buffer (fn [] 0)
                                 :maps [{:mode [:n :v :o]
                                         :lhs :q
                                         :rhs (fn [effects window]
                                                (fn []
                                                  (effects:close)))}]})
                   (builder.Beside (-> (builder.For {:buffer (fn [] 0)
                                                     :maps []}))
                                   0.5)
                   (builder.Padding 5)
                   (builder.Build (effects:new))))

; (painter root-frame)
{: root-frame : builder : effects}
