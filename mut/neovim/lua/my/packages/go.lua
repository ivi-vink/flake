local M = {}
local go = require("go")
local gotest = require("go.gotest")
go.setup {
  test_efm             = false, -- errorfomat for quickfix, default mix mode, set to true will be efm only
  luasnip              = true,

  goimports            = false,
  fillstruct           = false,
  gofmt                = false,
  max_line_len         = nil,
  tag_transform        = false,
  test_dir             = false,
  comment_placeholder  = "   ",
  icons                = false,
  verbose              = false,
  log_path             = vim.fn.expand("~/tmp/gonvim.log"),
  lsp_cfg              = false,
  lsp_gofumpt          = false,
  lsp_on_attach        = nil,
  lsp_keymaps          = false,
  lsp_codelens         = false,
  diagnostic           = false,
  lsp_inlay_hints      = {enable= false},
  gopls_remote_auto    = false,
  gocoverage_sign      = "█",
  sign_priority        = 7,
  dap_debug            = false,
  dap_debug_gui        = false,
  dap_debug_keymap     = false,
  dap_vt               = false,
  textobjects          = false,
  gopls_cmd            = nil,
  build_tags           = "",
  test_runner          = "go",
  run_in_floaterm      = false,
  iferr_vertical_shift = 4,
}

local efm = function()
  local indent = [[%\\%(    %\\)]]
  local efm = [[%-G=== RUN   %.%#]]
  efm = efm .. [[,%-G]] .. indent .. [[%#--- PASS: %.%#]]
  efm = efm .. [[,%G--- FAIL: %\\%(Example%\\)%\\@= (%.%#)]]
  efm = efm .. [[,%G]] .. indent .. [[%#--- FAIL: (%.%#)]]
  efm = efm .. [[,%A]] .. indent .. [[%\\+%[%^:]%\\+: %f:%l: %m]]
  efm = efm .. [[,%+Gpanic: test timed out after %.%\\+]]
  efm = efm .. ',%+Afatal error: %.%# [recovered]'
  efm = efm .. [[,%+Afatal error: %.%#]]
  efm = efm .. [[,%+Apanic: %.%#]]
  --
  -- -- exit
  efm = efm .. ',%-Cexit status %[0-9]%\\+'
  efm = efm .. ',exit status %[0-9]%\\+'
  -- -- failed lines
  efm = efm .. ',%-CFAIL%\\t%.%#'
  efm = efm .. ',FAIL%\\t%.%#'
  -- compiling error

  efm = efm .. ',%A%f:%l:%c: %m'
  efm = efm .. ',%A%f:%l: %m'
  efm = efm .. ',%f:%l +0x%[0-9A-Fa-f]%\\+' -- pannic with adress
  efm = efm .. ',%-G%\\t%\\f%\\+:%\\d%\\+ +0x%[0-9A-Fa-f]%\\+' -- test failure, address invalid inside
  -- multi-line
  efm = efm .. ',%+G%\\t%m'
  -- efm = efm .. ',%-C%.%#' -- ignore rest of unmatched lines
  -- efm = efm .. ',%-G%.%#'

  efm = string.gsub(efm, ' ', [[\ ]])
  -- log(efm)
  return efm
end
gotest.efm = efm
M.efm = efm
return M
