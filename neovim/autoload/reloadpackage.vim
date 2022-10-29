function reloadpackage#complete(arg_lead, cmd_line, cursor_pos)
    return luaeval("require('vimrc').reload_package_complete('" . a:arg_lead . "', '" . a:cmd_line . "', '" . a:cursor_pos . "')")
endfunction
