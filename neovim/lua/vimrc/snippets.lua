local ls = require "luasnip"
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local fmt = require("luasnip.extras.fmt").fmt
local m = require("luasnip.extras").m
local lambda = require("luasnip.extras").l
local postfix = require("luasnip.extras.postfix").postfix

local map = vim.api.nvim_set_keymap

local M = {}

local go_snippets = function()
    ls.add_snippets("go", {

        s(";r", fmt([[
            <>, err := <>
            if err != nil {
                <>
            }
        ]], {
            i(1,"ret"), i(2,"fun"), i(3, "return err")
        }, {
            delimiters = "<>"
        })),

        s(";e", fmt([[
            if <>, <> := <>; <> {
                <>
            }
        ]], {
            i(1,"v"),i(2,"err"),i(3,"fun"), i(4, "err != nil"), i(5,"return err")
        }, {
            delimiters = "<>"
        })),

        s(";fr", fmt([[
            for <>, <> := range <> {
                <>
            }
        ]], {
            i(1,"_"),i(2,"_"), i(3,"iterable"), i(4,"body")
        }, {
            delimiters = "<>"
        })),

        s(";sj", fmt([[
            <> <> `json:"<>"`
        ]], {
            i(1,"field"),i(2,"type"), d(3, function(args)
                for i, line in pairs(args[1]) do
                    args[1][i] = line:gsub("(%u)", function(ch) return '_' .. ch:lower() end):gsub("^_", '')
                end
                return sn(nil, {i(1,args[1])})
            end,
        {1})
        }, {
            delimiters = "<>"
        })),

        s(";test", fmt([[
func Test<>(t *testing.T) {
	for i, c := range []struct {
		expected <>
	}{
	} {
		t.Run(fmt.Sprintf("%d %s", i, c.expected), func(t *testing.T) {
            <>
		})
	}
}
        ]], {
            i(1,"test"),i(2,"type"), i(3,"body")
        }, {
            delimiters = "<>"
        })),



    })
end


function M.setup()
    go_snippets()
    ls.config.setup({
        load_ft_func =
        -- Also load both lua and json when a markdown-file is opened,
        -- javascript for html.
        -- Other filetypes just load themselves.
        require("luasnip.extras.filetype_functions").extend_load_ft({
            markdown = { "lua", "json" },
            html = { "javascript" }
        })
    })
    -- press <Tab> to expand or jump in a snippet. These can also be mapped separately
    -- via <Plug>luasnip-expand-snippet and <Plug>luasnip-jump-next.
    vim.keymap.set(
        "i",
        "<Tab>",
        [[luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>']],
        { silent = true, noremap = true, expr = true }
    )
    vim.keymap.set(
        { "i", "s" },
        "<S-Tab>",
        [[<cmd>lua require'luasnip'.jump(-1)<CR>]],
        { silent = true, noremap = true }
    )
    vim.keymap.set(
        "s",
        "<Tab>",
        [[<cmd>lua require'luasnip'.jump(1)<CR>]],
        { silent = true, noremap = true }
    )
    vim.keymap.set(
        { "i", "s" },
        "<C-E>",
        [[luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>']],
        { silent = true, noremap = true, expr = true }
    )
end

return M
