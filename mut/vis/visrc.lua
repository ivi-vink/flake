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

vis:map(m.NORMAL, "<M-x>b", function()
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

vis:map(m.NORMAL, "<M-x>~", function()
  vis:command("cd " .. vis.win.file.path:match("(.+)/[^/]+$"))
  return true;
end)
vis:map(m.NORMAL, "<M-x>f", function()
  local code, result, err = vis:pipe("", "vis-open .")
  if result then

    if not os.execute("cd " .. result) then
      vis:command("e " .. result)
    else
      vis:command("cd " .. result)
      local code, result, err = vis:pipe("", "lf --print-selection")
      if not result then return true end
      local lines = {}
      for line in result:gmatch("[^\n]+") do table.insert(lines, line) end
      if lines[1] then
        vis:command("e " .. lines[1])
      end
    end
    return true;
  end
  return true;
end)
vis:map(m.NORMAL, "<M-x>-", function()
  local code, result, err = vis:pipe("", "lf --print-selection")
  vis:command("cd " .. err)
  if result then
    vis:command("e " .. result)
  end
  return true;
end)
