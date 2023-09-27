(tset package.loaded :conf.wict-nvim.frames.frame nil)
(local vec (require :conf.wict-nvim.frames.vec))
(local frame (require :conf.wict-nvim.frames.frame))
(local m {})

;; Creates a new painter that wraps the paint and close methods of a painter
(local transform-painter (fn [painter ori width height]
                           (fn [frm]
                             (local coord (frame.frame->coord frm))
                             (local new-ori (coord ori))
                             (local new-frame
                                    (frame new-ori
                                           (vec.sub (coord width) new-ori)
                                           (vec.sub (coord height) new-ori)))
                             (painter new-frame))))

(local pad (fn [painter pad-size]
             (fn [frm]
               (local pad-width (/ pad-size (frame.width frm)))
               (local pad-height (/ pad-size (frame.height frm)))
               (local transformed
                      (transform-painter painter (vec.vec pad-width pad-height)
                                         (vec.vec (- 1 pad-width) pad-height)
                                         (vec.vec pad-width (- 1 pad-height))))
               (transformed frm))))

(local beside (fn [p1 p2 size]
                (local size (or size 0.5))
                (local left
                       (transform-painter p1 (vec.vec 0 0) (vec.vec size 0)
                                          (vec.vec 0 1)))
                (local right
                       (transform-painter p2 (vec.vec size 0) (vec.vec 1 0)
                                          (vec.vec size 1)))
                (fn [frm]
                  (left frm)
                  (right frm))))

(local builder {})

(fn builder.Padding [self size]
  (table.insert self.partial-painters {:op :pad : size})
  self)

(fn builder.Beside [self partial-builder size]
  (table.insert self.partial-painters {:op :beside : partial-builder : size})
  self)

(fn builder.LeftOf [self partial-builder size]
  (table.insert self.partial-painters {:op :left : partial-builder : size})
  self)

(fn builder.RightOf [self partial-builder size]
  (table.insert self.partial-painters {:op :right : partial-builder : size})
  self)

(fn builder.build-painter [self effects]
  (accumulate [painter (fn [frame] (print :leaf-painter)) _ partial-painter (ipairs self.partial-painters)]
    (do
      (match partial-painter
        {:op :pad : size} (do
                            (pad painter size))
        {:op :left : partial-builder} (do
                                        (beside painter
                                                (partial-builder:build-painter effects)
                                                partial-painter.size))
        {:op :right : partial-builder} (do
                                         (beside (partial-builder:build-painter effects)
                                                 painter partial-painter.size))
        {:op :beside : partial-builder} (do
                                          (beside painter
                                                  (partial-builder:build-painter effects)
                                                  partial-painter.size))
        {: maps : buffer} (do
                            (local window (effects:new-window maps))
                            (local painter-ptr painter)
                            (fn [frm]
                              (local frame-opts
                                     (frame.frame->open-win-options frm))
                              (local buf (buffer))
                              (if (not (window:open?))
                                  (window:open buf frame-opts)
                                  (window:repaint buf frame-opts))
                              (painter-ptr frm)))
        _ painter))))

(fn builder.Build [self effects]
  (local painter (self:build-painter effects))
  (fn [frm]
    (effects:attach)
    (painter frm)))

(fn builder.For [partial-painter]
  (local bldr {:partial-painters [partial-painter]})
  (setmetatable bldr builder)
  (set builder.__index builder)
  bldr)

builder
