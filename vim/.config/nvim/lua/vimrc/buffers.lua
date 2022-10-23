local M = {}

function M.clean_trailing_spaces()

    local save_cursor = vim.fn.getpos(".")
    local old_query = vim.fn.getreg("/")
    vim.cmd [[%s/\s\+$//e]]

    vim.fn.setpos(".", save_cursor)
    vim.fn.setreg("/", old_query)
end

function M.setup_white_space_highlight(bufnr)
    if vim.b.vimrc_trailing_white_space_highlight_enabled then
        return
    end

    -- if options.get_option_value("trailingwhitespacehighlight", bufnr) == false then
    --     return
    -- end

    vim.cmd([[highlight link TrailingWhiteSpace Error]])
    vim.cmd([[highlight NonText ctermfg=7 guifg=gray]])

    vim.cmd("augroup vimrc_trailing_white_space_highlight_buffer_" .. bufnr)
    vim.cmd([[autocmd! * <buffer>]])
    vim.cmd([[autocmd BufReadPost <buffer> match TrailingWhiteSpace /\s\+$/]])
    vim.cmd([[autocmd InsertEnter <buffer> match TrailingWhiteSpace /\s\+\%#\@<!$/]])
    vim.cmd([[autocmd InsertLeave <buffer> match TrailingWhiteSpace /\s\+$/]])
    vim.cmd([[augroup END]])

    vim.b.vimrc_trailing_white_space_highlight_enabled = true
end

return M
