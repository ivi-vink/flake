;; cannot be at the bottom?
(fn settings [...]
  (fn echo [l] (each [k v (ipairs l)] (print k v)))
  (fn tbl-echo [tbl] (collect [k v (pairs tbl)] (print k v) (values k v)))

  (fn stringify [l] (icollect [_ v (ipairs l)] (tostring v)))

  (fn kv [l tbl] 
    (let [[first second & rest] l] 
      (when (and (not= first nil) (not= second nil))
       (tset tbl first second)
       (kv rest tbl))
      tbl))

  (let [opts-tbl (-> [...]
                     (stringify)
                     (kv {}))]
    `(each [k# v# (pairs ,opts-tbl)] 
      (match [k# v#]
       [a# "true"] (tset (. vim "opt") k# true)
       [a# "false"] (tset (. vim "opt") k# false)
       [a# b#] (tset (. vim "opt") k# v#)))))

{: settings}
