(fn by-two [l]
  (fn iter [t i]
    (let [k (. l (- i 1))
          v (. l i)]
      (when (and (not= k nil) (not= v nil))
        (values (+ i 2) [k v]))))

  (values iter l 2))

(fn decode-opt-value [v]
  (fn symbol-luatype [s]
    (let [t (tostring s)]
      (match t
        :on true
        :off false
        _ t)))

  (if (sym? v) (symbol-luatype v) v))

(fn opt-template [o]
  (fn remove/append [target value mode]
    `(let [target# (. vim :opt ,target)
           value# ,value]
       ,(match mode
          :append `(target#:append value#)
          :remove `(target#:remove value#))))

  (fn [v]
    (match (string.sub o 1 1)
      "-" (remove/append (string.sub o 2) v :remove)
      "+" (remove/append (string.sub o 2) v :append)
      _ `(tset (. vim :opt) ,o ,v))))

(fn settings [...]
  `,(icollect [_ [o v] (by-two [...])]
      ((opt-template (tostring o)) (decode-opt-value v))))

(fn globals [...]
  (local globa (icollect [_ [k v] (by-two [...])]
                 [(tostring k) v]))
  `(let [l# ,globa]
     (each [a# b# (ipairs l#)]
       (tset (. vim :g) (. b# 1) (. b# 2)))))

(fn P [...]
  `(print (vim.inspect [...])))

{: P : settings : globals}
