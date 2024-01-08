(local lint (require :lint))
(set
  lint.linters_by_ft
  {:markdown [:vale]
   :sh [:shellcheck]})

