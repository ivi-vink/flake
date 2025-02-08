-- load standard vis module, providing parts of the Lua API
require('vis')
require('vis-editorconfig')
local quickfix = require('vis-quickfix')
local format = require('vis-format')
local m = vis.modes

quickfix.grepprg = "rg --hidden --no-ignore-vcs --vimgrep"

vis.ftdetect.filetypes.terraform = {
  ext = { "%.tf$" },
}
for k, _ in pairs(format.formatters) do
	format.formatters[k] = nil
end
format.formatters.python = format.stdio_formatter("ruff format -", {on_save=true})
format.formatters.terraform = format.stdio_formatter("terraform fmt -", {on_save=true})

vis.events.subscribe(vis.events.INIT, function()
  vis:command"set shell '/usr/bin/bash'"
  vis:command"set edconfhooks on"
  vis:command"set change256colors off"
  vis:command"set theme lemonsoda"

  vis:map(m.INSERT,      '<C-r>"', '<C-r>+')
  vis:map(m.NORMAL,      'y', '<vis-register>+<vis-operator-yank>')
  vis:map(m.VISUAL,      'y', '<vis-register>+<vis-operator-yank>')
  vis:map(m.VISUAL_LINE, 'y', '<vis-register>+<vis-operator-yank>')
  vis:map(m.NORMAL,      'd', '<vis-register>+<vis-operator-delete>')
  vis:map(m.VISUAL,      'd', '<vis-register>+<vis-operator-delete>')
  vis:map(m.VISUAL_LINE, 'd', '<vis-register>+<vis-operator-delete>')
  vis:map(m.NORMAL,      'p', '<vis-register>+<vis-put-after>')
  vis:map(m.VISUAL,      'p', '<vis-register>+<vis-put-after>')
  vis:map(m.VISUAL_LINE, 'p', '<vis-register>+<vis-put-after>')
  vis:map(m.NORMAL,      'P', '<vis-register>+<vis-put-before>')
  vis:map(m.VISUAL,      'P', '<vis-register>+<vis-put-before>')
  vis:map(m.VISUAL_LINE, 'P', '<vis-register>+<vis-put-before>')
end)

local files = {}
vis.events.subscribe(vis.events.WIN_OPEN, function(win)
  vis:command"set cul on"
  vis:command"set number"
  vis:command"set relativenumber"
  vis:command"set change256colors off"
  local radix = files[vis.win.file.path]
  for p, i in pairs(files) do
    if (radix == nil) or (radix >= i) then
      files[p] = i + 1
    end
  end
  if vis.win.file.path then
    files[vis.win.file.path] = 0
  end
end)

vis:map(m.NORMAL, "<C-x>b", function()
  local keys = {}
  for k in pairs(files) do if k ~= vis.win.file.path then table.insert(keys, k) end end
  if next(keys) == nil then
    return true
  end
  table.sort(keys, function(a, b) return files[a] < files[b] end)
  local code, result, err = vis:pipe(table.concat(keys, "\n"), "vis-menu -l 3")
  if result then
    vis:command("e " .. result)
  end
  return true;
end)

local parent = function(filename)
  if filename ~= nil then
    return filename:match("(.+)/[^/]+$")
  end
  return nil
end

local lfcd = function(cd_or_select_path)
  local code, result, err = vis:pipe("", "lf --print-selection " .. cd_or_select_path)
  vis:command("cd " .. err)
  if result then
    vis:command("e " .. result)
  end
  return true;
end

vis:map(m.NORMAL, "<C-x>~", function()
  vis:command("cd " .. (parent(vis.win.file.path) or "."))
  return true;
end)
vis:map(m.NORMAL, "<C-x><C-f>", function()
  local code, result, err = vis:pipe("", "vis-open " .. (parent(vis.win.file.path) or "."))
  if result then
    if not os.execute("cd " .. result) then
      vis:command("e " .. result)
    else
      return lfcd(result)
    end
    return true;
  end
  return true;
end)
vis:map(m.NORMAL, "<C-x>-", function()
  return lfcd(parent(vis.win.file.path) or "")
end)
vis:map(m.NORMAL, "<C-x>_", function()
  return lfcd(".")
end)
