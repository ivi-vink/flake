(local lint (require :lint))

(fn executable? [program]
  (fn []
    (= 1 (vim.fn.executable program))))

(set
  lint.linters_by_ft
  {:markdown (if (executable? :vale) [:vale] [])
   :python (if (executable? :ruff) [:ruff] [])
   :sh [:shellcheck]})


(local conform (require :conform))
(conform.setup
  {:formatters_by_ft
   {:python [:ruff_format :isort]
    :go [:goimports]
    :terraform [:terraform_fmt]}
   :format_on_save
   {:timeout_ms 500
    :lsp_fallback false}})
