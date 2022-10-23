local vim = vim
local cmd = vim.cmd
local M = {}

-- paths {{{
-- }}}
--
-- logging {{{
function M.log_error(msg, source, persist)
    if source then
        msg = "[" .. source .. "] " .. msg
    end
    cmd [[echohl ErrorMsg]]
    if persist then
        cmd("echomsg '" .. msg .. "'")
    else
        cmd("echo '" .. msg .. "'")
    end
    cmd [[echohl Normal]]
end

function M.log_warning(msg, source, persist)
    if source then
        msg = "[" .. source .. "]" .. msg
    end
    msg = string.gsub(msg, "'", '"')
    cmd [[echohl WarningMsg]]
    if persist then
        cmd("echomsg '" .. msg .. "'")
    else
        cmd("echo '" .. msg .. "'")
    end
    cmd [[echohl Normal]]
end
-- }}}

-- tables {{{
function table.filter()
    print"hi"
end

function table.keys(tbl)
    local k = {}
    for key, val in pairs(tbl) do
        table.insert(k, key)
    end
    return k
end

-- }}}

-- string {{{
function string.join(str, join_token)
    local j = ""
    local join = join_token or ""
    if #str == 1 then
        return str[1]
    end
    for i, token in ipairs(str) do
        if i > 1 then
            j = j .. join .. token
        else 
            j = j .. token
        end
    end
    return j
end
-- }}}
return M
-- vim: fdm=marker
