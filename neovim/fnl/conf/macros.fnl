;; cannot be at the bottom?

(fn settings [...]
  (fn stringify [l]
    (icollect [_ v (ipairs l)]
      (tostring v)))

  (fn ->tbl [l]
    (local tbl {})

    (fn iter [i]
      (let [k (. l (- i 1))
            v (. l i)]
        (when (and k v)
          (tset tbl k v)
          (iter (+ i 2)))))

    (iter 2)
    tbl)

  (fn value-type [v]
    (match v
      :on true
      :no false
      v v))

  (fn template [k v method]
    `(let [s# (. vim :opt ,k)
           t# ,(value-type v)]
       ,(match method
          :append `(s#:append t#)
          :remove `(s#:remove t#)
          :set `(tset (. vim :opt) ,k t#))))

  (fn transform [tbl]
    (icollect [k v (pairs tbl)]
      (match (string.sub k 1 1)
        "+" (template (string.sub k 2) v :append)
        "-" (template (string.sub k 2) v :remove)
        _ (template k v :set))))

  (let [l (-> [...]
              (stringify)
              (->tbl)
              (transform))]
    `,l))

(fn globals [...])
  
;; (let [opts-tbl (-> [...]
;;                   (stringify)
;;                   (->tbl {}))]
;;  `(each [k# v# (pairs ,opts-tbl)]
;;     (match [k# v#]
;;       [a# :true] (tset (. vim :opt) k# true)
;;       [a# :false] (tset (. vim :opt) k# false)
;;       [a# b#] (tset (. vim :opt) k# v#)))))

(fn P [p]
  `(print (vim.inspect ,p)))

{: P : settings : globals}
