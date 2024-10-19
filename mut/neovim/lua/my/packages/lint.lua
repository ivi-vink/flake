local lint = require("lint")
local conform = require("conform")

function is_executable(program)
  return vim.fn.executable(program) == 1
end

lint.linters_by_ft = {
  markdown=ternary(is_executable("vale"), { "vale" }, {}),
  python=ternary(is_executable("ruff"), { "ruff" }, {}),
  sh={ "shellcheck" },
}

conform.setup {
  formatters_by_ft={
    python= { "ruff_format", "isort" },
    go= { "goimports" },
    nix= { "alejandra" },
    terraform= { "terraform_fmt" },
    hcl= { "terraform_fmt" },
  },
  format_on_save={
    timeout_ms= 500,
    lsp_fallback= false
  }
}
