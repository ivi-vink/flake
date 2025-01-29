-- SPDX-License-Identifier: GPL-3.0-or-later
-- © 2020 Georgi Kirilov

require("vis")
local vis = vis

local getcwd

if vis:module_exist"lfs" then
	require"lfs"
	local lfs = lfs

	getcwd = lfs.currentdir
else
	getcwd = function()
		return io.popen"pwd":read"*l"
	end
end

local progname = ...

local M = {
	grepformat  = {
		"^%s*([^:]+):(%d+):(%d+):(.*)$", -- git-grep with --column
		"^%s*([^:]+):(%d+):(.-)(.*)$",
	},
	errorformat = {
		"^%s*([^:]+):(%d+):(%d+):(.*)$",
		"^%s*([^:]+):(%d+):(.-)(.*)$",
		"^(%S+) %S+ (%d+) (.-)(.*)$", -- cscope
		[0] = {
			["Entering directory [`']([^']+)'"] = true,
			["Leaving directory [`']([^']+)'"] = false,
		},
	},
	grepprg = "grep -n",
	makeprg = "make -k",
	errorfile = "errors.err",
	peek = true,
	menu = false,
	action = {},
}

local cwin
local ctitle
local lines = {valid = {}}
local no_more = "No more items"
local no_errors = "No Errors"

local function find_nearest_after(line)
	local ccur
	for c, v in ipairs(lines.valid) do
		if v[1] >= line then
			ccur = c
			break
		end
	end
	if not ccur then
		return nil, no_more
	end
	return {ccur, lines.valid[ccur][1]}
end

local function find_nth_valid(count)
	if count < 1 or count > #lines.valid then
		return nil, no_more
	end
	return {count, lines.valid[count][1]}
end

local function set_marks(win, ccur)
	if not ccur then return end
	local fname = win.file.name
	local pwd = getcwd()
	local pathname = fname:find("^/") and fname or pwd .. "/" .. fname
	local i = ccur
	while lines.valid[i] and lines.valid[i].path == pathname do
		i = i - 1
	end
	local ln = lines.valid[i + 1]
	while ln and ln.path == pathname do
		-- I wish there was a way to convert from ln:col to pos
		-- without setting the selection
		win.selection:to(ln.line, ln.column or 1)
		ln.mark = win.file:mark_set(win.selection.pos)
		i = i + 1
		ln = lines.valid[i]
	end
end

local function botright_reopen(filename, ccur)
	-- This function closes and opens windows in a specific order, just so
	-- the error window ends up at bottom position.
	-- This is fragile, and does not work in all possible situations.
	-- Having a window with a modified file is one example.
	-- Even if the file was not modified, closing the window will lead to loss of
	-- any state local to it.
	-- It would be nice if vis had :botright or something to that effect.
	local cursors = {}
	for w in vis:windows() do
		if w.file.name then
			cursors[w.file.name] = w.selection.pos
		end
		if cwin and w ~= cwin then
			w:close()
		end
	end
	for w in vis:windows() do
		if w.file.name and w.file.modified then
			vis:info"No write since last change"
			return false
		end
	end
	if filename then
		vis:command(string.format((cwin and "open" or "e") .. " %q", filename))
		set_marks(vis.win, ccur)
		if cursors[filename] then
			vis.win.selection.pos = cursors[filename]
		end
	else
		vis:command"new"
	end
	return true
end

local function counter(ccur)
	return string.format("%s/%d",
		ccur or "-",
		#lines.valid)
end

local function display(ccur, cline)
	local ln = lines.valid[ccur]
	local pwd = getcwd()
	local cname = ln.path:find(pwd) and ln.path:gsub(pwd, "", 1):gsub("^/", "") or ln.path
	if vis.win.file.name ~= cname then
		if not botright_reopen(ln.path, ccur) then return end
	end
	local column = ln.column
	if type(column) ~= "number" then
		column = nil
	-- else
	-- 	TODO: some tools report virtual columns, others - physical.
	-- 	local indent = vis.win.file.lines[ln.line]:match"^%s+" or ""
	-- 	local _, tabs = indent:gsub("\t", "")
	-- 	-- XXX: assume tools to report 8 columns-wide tabs
	-- 	column = column - tabs * 8 + tabs
	end
	if cwin then
		cwin.selection:to(cline, 1)
		local pos = cwin.selection.pos
		local clen = cwin.file.lines[cline]
		lines.range = {start = pos, finish = pos + #clen - 1}
	end
	if ln.mark then
		local newpos = vis.win.file:mark_get(ln.mark)
		if newpos then
			vis.win.selection.pos = newpos
		end
	else
		-- XXX: degrade to using raw line:column;
		-- so far, only triggered by consecutive hard links
		-- where vis keeps the old file.name but the error list
		-- switches to the new. set_marks gets confused and sets no marks.
		vis.win.selection:to(ln.line, column or 1)
	end
	if not cwin and ln.message then
		vis:info(string.format("[%s] %s", counter(ccur), ln.message:gsub("^%s", "")))
	end
	lines.ccur = ccur
	lines.cline = cline
end

local function _cc(count)
	if not count then return end
	local location, err = find_nth_valid(count)
	if not location then
		vis:info(err)
		return
	end
	return table.unpack(location)
end

local function guard(func)
	return function(...)
		if #lines.valid == 0 then
			vis:info(no_errors)
			return
		end
		local ccur, cline = func(...)
		if ccur and cline then
			display(ccur, cline)
		end
	end
end

local cc = guard(function(count)
	return _cc(count or lines.ccur or 1)
end)

local cnext = guard(function(count)
	return _cc((lines.ccur or 0) + (count or 1))
end)

local cprev = guard(function(count)
	return _cc((lines.ccur or 2) - (count or 1))
end)

local crewind = guard(function()
	return _cc(1)
end)

local clast = guard(function()
	return _cc(#lines.valid)
end)

local cnfile = guard(function(count)
	count = count or 1
	if not lines.ccur then
		lines.ccur = 1
	end
	local cur_fname = lines.valid[lines.ccur].path
	for i = lines.ccur + 1, #lines.valid do
		local filename = lines.valid[i].path
		if filename then
			if filename ~= cur_fname then
				count = count - 1
			end
			if count == 0 then
				return i, lines.valid[i][1]
			end
		end
	end
	vis:info(no_more)
end)

local cpfile = guard(function(count)
	count = count or 1
	if not lines.ccur then
		lines.ccur = 1
	end
	local cur_fname = lines.valid[lines.ccur].path
	for i = lines.ccur - 1, 1, -1 do
		local filename = lines.valid[i].path
		if filename then
			if filename ~= cur_fname then
				count = count - 1
			end
			if count == 0 then
				return i, lines.valid[i][1]
			end
		end
	end
	vis:info(no_more)
end)

local function open_error_window()
	if cwin then return end
	if not ctitle then
		vis:info(no_errors)
		return
	end
	local fname = vis.win.file.name
	vis:command"new"
	cwin = vis.win
	cwin.file:insert(0, lines.buffer or "")
	cwin.file.modified = false
	local cline1
	if lines.cline then
		cline1 = lines.cline
	else
		local first = find_nth_valid(1)
		cline1 = first and first[2] or 1
	end
	cwin.selection:to(cline1, 1)
	if lines.cline then
		local pos = cwin.selection.pos
		local clen = cwin.file.lines[lines.cline]
		lines.range = {start = pos, finish = pos + #clen - 1}
	end
	if #lines.valid > 0 then
		if cwin.options then
			cwin.options.cursorline = true
		else
			vis:command"set cursorline"
		end
	end
	cwin:map(vis.modes.NORMAL, "<Enter>", function()
		if #lines.valid == 0 then
			vis:info(no_errors)
			return
		end
		local location, err = find_nearest_after(vis.win.selection.line)
		if not location then
			vis:info(err)
			return
		end
		display(table.unpack(location))
		if M.menu then
			cwin:close()
		end
	end)
	botright_reopen(fname, lines.ccur)
	vis:feedkeys"<vis-window-prev>"
end

local function cwindow()
	if cwin then
		cwin:close(true)
	else
		open_error_window()
	end
end

local function store_from_string(str, fmt)
	if str and string.len(str) == 0 then
		str = nil
	end
	lines = {buffer = str, valid = {}}
	if not lines.buffer then return end
	if not fmt then
		fmt = M.errorformat
	elseif type(fmt) == "string" then
		fmt = {fmt}
	end
	local i = 0
	local dirstack = {}
	local pwd = getcwd()
	for ln in lines.buffer:gmatch("[^\n]+") do
		i = i + 1
		for patt, push in pairs(fmt[0] or {}) do
			local dir = ln:match(patt)
			if dir then
				if push then
					table.insert(dirstack, dir)
				elseif dirstack[#dirstack] == dir then
					table.remove(dirstack)
				end
			end
		end
		local cwd = dirstack[#dirstack] or pwd
		local filename, line, column, message
		for _, f in ipairs(fmt) do
			filename, line, column, message = ln:match(f)
			if filename and line then
				break
			end
		end
		if filename and line then
			local pathname = filename:find("^/") and filename or string.format("%s/%s", cwd, filename)
			local t = {i, path = pathname, line = tonumber(line), column = tonumber(column), message = message}
			table.insert(lines.valid, t)
		end
	end
end

local function store_from_file(errorfile)
	if errorfile then
		M.errorfile = errorfile
	end
	local efile = io.open(errorfile or M.errorfile)
	if not efile then
		vis:info(string.format("Can't open errorfile %s", errorfile or M.errorfile))
		return
	end
	local str = efile:read"*all"
	efile:close()
	store_from_string(str)
	return true
end

local function store_from_window(win)
	local str = win.file:content(0, win.file.size)
	store_from_string(str)
end

local function cfile(argv)
	if store_from_file(argv[1]) then
		local was_open
		if cwin then
			cwin:close(true)
			was_open = true
		end
		ctitle = string.format(argv[1] and "%s %s" or "%s", argv[0], argv[1])
		if was_open then
			open_error_window()
		end
		crewind()
	end
end

local function cbuffer(argv)
	store_from_window(vis.win)
	local fname = vis.win.file.name
	ctitle = string.format(fname and "%s (%s)" or "%s", argv[0], fname)
	vis.win.file.modified = false
	crewind()
end

local function _cexpr(cmd, fmt, title, is_make)
	if not cmd or #cmd == 0 then vis:info"Argument required" return end
	ctitle = title or cmd
	local code, stdout = vis:pipe(nil, nil, cmd .. " 2>&1")
	local was_open
	if cwin then
		cwin:close(true)
		was_open = true
	end
	store_from_string(stdout, fmt)
	lines.code = code ~= 0 and code or nil
	if is_make and code == 0 then
		vis:info(string.format("'%s' finished", M.makeprg))
		return
	end
	if was_open or M.peek or #lines.valid == 0 then
		open_error_window()
	end
	if not M.peek and #lines.valid > 0 then
		crewind()
	end
end

local function quote_spaces(argv)
	for i, arg in ipairs(argv) do
		if arg:find("[ \t\n]") then
			argv[i] = "'" .. arg .. "'"
		end
	end
end

local function cexpr(argv)
	quote_spaces(argv)
	_cexpr(table.concat(argv, " "))
end

local function grep(argv)
	quote_spaces(argv)
	table.insert(argv, 1, M.grepprg)
	_cexpr(table.concat(argv, " "), M.grepformat)
end

local function make(argv)
	quote_spaces(argv)
	table.insert(argv, 1, M.makeprg)
	_cexpr(table.concat(argv, " "), M.errorformat, nil, true)
end

local function h(msg)
	return string.format("|@%s| %s", progname, msg)
end

vis.events.subscribe(vis.events.INIT, function()
	-- These commands assume an existing error list:
	local ccommands = {
		cn  = {cnext,   "Display the [arg]-th next error"},
		cp  = {cprev,   "Display the [arg]-th previous error"},
		cnf = {cnfile,  "Display the first error in the [arg]-th next file"},
		cpf = {cpfile,  "Display the last error in the [arg]-th previous file"},
		cc  = {cc,      "Display [arg]-th error. If [arg] is omitted, the same error is displayed again."},
		cr  = {crewind, "Display the first error"},
		cla = {clast,   "Display the last error"},
	}
	-- These commands create a new error list:
	local qcommands = {
		cf   = {cfile,   "Read the error list from [arg]"},
		cb   = {cbuffer, "Read the error list from the current file"},
		cex  = {cexpr,   "Create an error list using the result of [args]"},
		grep = {grep,    string.format("Create an error list using the result of '%s'", M.grepprg)},
		make = {make,    string.format("Create an error list using the result of '%s'", M.makeprg)},
		cw   = {cwindow, "Toggle the error window"},
	}
	for cmd, def in pairs(ccommands) do
		local func, help = table.unpack(def)
		vis:command_register(cmd, function(argv)
			local count = argv[1] and tonumber(argv[1])
			func(count)
		end, h(help))
		M.action[cmd] = function(arg)
			-- XXX: do not convert, say, "1" to 1; a digit can be passed by vis.map but it is not a count
			local count = type(arg) == "number" and arg
			func(count)
		end
	end
	for cmd, def in pairs(qcommands) do
		local func, help = table.unpack(def)
		vis:command_register(cmd, func, h(help))
	end
	M.cexpr = _cexpr
	vis:option_register("qfm", "bool", function(value, toggle)
		if toggle then
			M.menu = not M.menu
		else
			M.menu = value
		end
	end, h"Menu - jumping to an error with <Enter> closes the error window")
	vis:option_register("qfp", "bool", function(value, toggle)
		if toggle then
			M.peek = not M.peek
		else
			M.peek = value
		end
	end, h"Peek - :make, :grep, and :cex do not jump to the first error")
end)

vis.events.subscribe(vis.events.WIN_STATUS, function(win)
	if win ~= cwin then return end
	win:status(
		string.format(" [Quickfix List]%s :%s", (win.file.modified and " [+]" or ""), ctitle),
		lines.code and string.format("exit: %d « [%s] ", lines.code, counter(lines.ccur))
				or string.format("[%s] ", counter(lines.ccur))
		)
end)

vis.events.subscribe(vis.events.WIN_CLOSE, function(win)
	if win ~= cwin then return end
	cwin = nil
end)

vis.events.subscribe(vis.events.WIN_HIGHLIGHT, function(win)
	if win ~= cwin then return end
	if not (lines and lines.range) then return end
	win:style(win.STYLE_CURSOR_PRIMARY, lines.range.start, lines.range.finish)
end)

return M
