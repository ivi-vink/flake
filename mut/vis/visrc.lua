-- load standard vis module, providing parts of the Lua API
require('vis')
local format = require('vis-format')
for k, _ in pairs(format.formatters) do
	format.formatters[k] = nil
end
format.formatters.python = format.stdio_formatter("ruff format -")

vis.events.subscribe(vis.events.INIT, function()
  vis:command"set shell '/usr/bin/bash'"
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
end)

vis.events.subscribe(vis.events.FILE_SAVE_PRE, function(win)
  format.apply(win)
end)
