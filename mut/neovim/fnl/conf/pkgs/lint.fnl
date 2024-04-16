(local lint (require :lint))
(set
  lint.linters_by_ft
  {:markdown [:vale]
   :python [:ruff]
   :sh [:shellcheck]})

(local conform (require :conform))
(conform.setup
  {:formatters_by_ft
   {:python [:ruff_format :isort]}
   :format_on_save
   {:timeout_ms 500
    :lsp_fallback false}})
