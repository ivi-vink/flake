_G.package["path"] = (vim.fn.stdpath("cache") .. "/hotpot/hotpot.nvim/lua/?/init.lua;" .. package.path)
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
  local opts = {verbosity = 0, compiler = {modules = {allowedGlobals = allowed_globals}}}
  local here
  local function _3_(_241)
    return _241
  end
  here = _3_
  local config_path = vim.fn.stdpath("config")
  return build(config_path, opts, (config_path .. "/init.fnl"), here, (config_path .. "/after/ftdetect/.+"), here, (config_path .. "/ftplugin/.+"), here, (config_path .. "/after/ftplugin/.+"), here)
end
do
  local hotpot = require("hotpot")
  local setup = hotpot.setup
  local build = hotpot.api.make.build
  local uv = vim.loop
  local config_path = vim.fn.stdpath("config")
  setup({provide_require_fennel = true, compiler = {modules = {correlate = true}, macros = {env = "_COMPILER", compilerEnv = _G, allowedGlobals = false}}})
  local handle = uv.new_fs_event()
  local path = vim.fn.expand((config_path .. "/init.fnl"))
  local function _4_()
    return vim.schedule(build_init)
  end
  uv.fs_event_start(handle, path, {}, _4_)
  local function _5_()
    return uv.close(handle)
  end
  vim.api.nvim_create_autocmd("VimLeavePre", {callback = _5_})
end
return require("conf")