(local m {})
(local vec {})

(fn vec.make [self x y]
  (local v {: x : y})
  (setmetatable v self)
  (set self.__index self)
  v)

(fn vec.x-coord [v]
  v.x)

(fn vec.y-coord [v]
  v.y)

(fn m.add [v1 v2]
  (vec:make (+ (v1:x-coord) (v2:x-coord)) (+ (v1:y-coord) (v2:y-coord))))

(fn m.sub [v1 v2]
  (vec:make (- (v1:x-coord) (v2:x-coord)) (- (v1:y-coord) (v2:y-coord))))

(fn m.scale [a v]
  (vec:make (math.floor (* a (v:x-coord))) (math.floor (* a (v:y-coord)))))

(fn m.vec [...]
  (vec:make ...))

m
