local function build_init()
  local _let_1_ = require("hotpot.api.make")
  local build = _let_1_["build"]
  local allowed_globals
  do
    local tbl_17_auto = {}
    local i_18_auto = #tbl_17_auto
    for n, _ in pairs(_G) do
      local val_19_auto = n
      if (nil ~= val_19_auto) then
        i_18_auto = (i_18_auto + 1)
        do end (tbl_17_auto)[i_18_auto] = val_19_auto
      else
      end
    end
    allowed_globals = tbl_17_auto
  end
  local opts = {verbosity = 1, compiler = {modules = {allowedGlobals = allowed_globals}}}
  local function _3_(_241)
    return _241
  end
  return build("/home/mike/dotnix/neovim/init.fnl", opts, ".+", _3_)
end
do
  local hotpot = require("hotpot")
  local setup = hotpot.setup
  local build = hotpot.api.make.build
  local uv = vim.loop
  setup({provide_require_fennel = true, compiler = {modules = {correlate = true}, macros = {env = "_COMPILER", compilerEnv = _G, allowedGlobals = false}}})
  local handle = uv.new_fs_event()
  local path = vim.fn.expand("/home/mike/dotnix/neovim/init.fnl")
  local function _4_()
    return vim.schedule(build_init)
  end
  uv.fs_event_start(handle, path, {}, _4_)
  local function _5_()
    return uv.close(handle)
  end
  vim.api.nvim_create_autocmd("VimLeavePre", {callback = _5_})
end
vim.g["mapleader"] = " "
vim.g["maplocalleader"] = " "
vim.cmd("colorscheme gruvbox-material")
for k_7_auto, v_8_auto in pairs({backup = "false", backupcopy = "yes"}) do
  local _6_ = {k_7_auto, v_8_auto}
  if ((_G.type(_6_) == "table") and (nil ~= (_6_)[1]) and ((_6_)[2] == "true")) then
    local a_9_auto = (_6_)[1]
    vim.opt[k_7_auto] = true
  elseif ((_G.type(_6_) == "table") and (nil ~= (_6_)[1]) and ((_6_)[2] == "false")) then
    local a_9_auto = (_6_)[1]
    vim.opt[k_7_auto] = false
  elseif ((_G.type(_6_) == "table") and (nil ~= (_6_)[1]) and (nil ~= (_6_)[2])) then
    local a_9_auto = (_6_)[1]
    local b_10_auto = (_6_)[2]
    vim.opt[k_7_auto] = v_8_auto
  else
  end
end
do
  local ts = require("nvim-treesitter.configs")
  ts.setup[{highlight = {enable = true}}]()
end
local cmp = require("cmp")
local snip
local function _8_(args)
  return (require("luasnip")).lsp_expand(args.body)
end
snip = _8_
return cmp.setup({snippet = {expand = snip}, completion = {autocomplete = false}, mapping = cmp.mapping.preset.insert({["<C-b>"] = cmp.mapping.scroll_docs(-4), ["<C-A>"] = cmp.mapping.complete()}), sources = cmp.config.sources({{name = "conjure"}, {name = "nvim_lsp"}, {name = "path"}, {name = "luasnip"}})})