-- load standard vis module, providing parts of the Lua API
require('vis')

vis.events.subscribe(vis.events.INIT, function()
  vis:command"set shell '/usr/bin/bash'"
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
end)

On branch master
Your branch is up to date with 'origin/master'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   justfile
	modified:   mut/aerospace/aerospace.toml
	modified:   mut/bin/pnsh-nvim
	modified:   mut/bin/xdg-open
	modified:   mut/neovim/lua/my/init.lua
	modified:   mut/nushell/config.nu

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	mut/carapace/specs/upctl.yaml
	mut/vis/
	nohup.out

no changes added to commit (use "git add" and/or "git commit -a")

