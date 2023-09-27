(local vec (require :conf.wict-nvim.frames.vec))
(local m {})
(local frame {})

;; frame is interpreted as matrix coords
;; origin ------------------> ne-edge
;; |
;; |
;; |
;; |
;; |
;; |
;;\ /
;; .
;; sw-edge
(fn frame.make [self ori width height]
  (local f {: ori : width : height})
  (setmetatable f self)
  (set self.__index self)
  f)

(fn frame.origin [f]
  f.ori)

(fn frame.width-edge [f]
  f.width)

(fn frame.height-edge [f]
  f.height)

(fn m.frame->coord [f]
  (fn [v]
    (vec.add (f:origin)
             (vec.add (vec.scale (v:x-coord) (f:width-edge))
                      (vec.scale (v:y-coord) (f:height-edge))))))

(fn m.width [f]
  (let [width-edge (f:width-edge)]
    (width-edge:x-coord)))

(fn m.height [f]
  (let [height-edge (f:height-edge)]
    (height-edge:y-coord)))

(fn m.frame->open-win-options [f anchor]
  (local coord (m.frame->coord f))
  (local ori (f:origin))
  (local width-edge (f:width-edge))
  (local height-edge (f:height-edge))
  (local anchor (or anchor :NW))
  {:width (width-edge:x-coord)
   :height (height-edge:y-coord)
   :col (ori:x-coord)
   :row (ori:y-coord)
   : anchor
   :relative :editor})

(setmetatable m {:__call (fn [self ...]
                           (frame:make ...))})

m
