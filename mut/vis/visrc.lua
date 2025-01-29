-- load standard vis module, providing parts of the Lua API
require('vis')
require('vis-editorconfig')

local format = require('vis-format')
for k, _ in pairs(format.formatters) do
	format.formatters[k] = nil
end
format.formatters.python = format.stdio_formatter("ruff format -", {on_save=true})


vis.events.subscribe(vis.events.INIT, function()
  vis:command"set shell '/usr/bin/bash'"
  vis:command"set edconfhooks on"
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
end)
