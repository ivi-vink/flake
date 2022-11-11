-- vim: fdm=marker
local log_warning = require 'vimrc.utils'.log_warning
local M = {}

M.cwd_save_session = function()
    vim.cmd([[
augroup vimrc_save_session
    au!
    au VimLeave * mksession! ]] .. os.getenv("PWD") .. [[/Session.vim
augroup end
    ]])
end

function M.setup_cmp()
    local cmp = require 'cmp'
    cmp.setup({
        snippet = {
            -- REQUIRED - you must specify a snippet engine
            expand = function(args)
                require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            end,
        },
        completion = {
            autocomplete = false
        },
        window = {
            -- completion = cmp.config.window.bordered(),
            -- documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-A>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
            { name = 'path' },
        })
    })
end

function M.setup_treesitter()
    if vim.o.loadplugins == false then
        return
    end

    if vim.fn.exists(":TSInstall") == 1 then
        return vim.notify "TreeSitter is already configured."
    end

    -- vim.cmd([[packadd nvim-treesitter]])
    require 'nvim-treesitter.configs'.setup {
        highlight = {
            enable = true,
            -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
            -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
            -- Using this option may slow down your editor, and you may see some duplicate highlights.
            -- Instead of true it can also be a list of languages
        },
        incremental_selection = {
            enable = true,
        },
        indent = {
            enable = true,
            disable = { "python", "yaml" },
        },
    }
    vim.cmd [[hi link TSParameter Todo]]
end

function M.setup_rest_nvim()
    require("rest-nvim").setup({
        result_split_horizontal = true,
        skip_ssl_verification = false,
        highlight = { enabled = true, timeout = 150 },
        jump_to_request = false,
    })

    local map = vim.api.nvim_set_keymap
    map(
        "n",
        "<leader>tt",
        "<Plug>RestNvim",
        { silent = true }
    )
    map(
        "n",
        "<leader>tp",
        "<Plug>RestNvimPreview",
        { silent = true }
    )
end

local jq_functions = {}
function M.setup_jq_function()
    jq_functions.filter_jq = function(path, first, last)
        P(path)
        local buf = vim.api.nvim_get_current_buf()
        first, last = tonumber(first), tonumber(last)
        first = first - 1
        local json_string = table.concat(vim.api.nvim_buf_get_lines(buf, first, last, true))
        local tmp = os.tmpname()
        local f = io.open(tmp, "w")
        if f then
            f:write(json_string)
            f:close()
        else
            return false
        end
        local cmd = {
            "/bin/sh",
            "-c",
            [[cat ]] .. tmp .. [[ | jq ']] .. path .. [[']]
        }
        require('firvish.job_control').start_job({
            cmd = cmd,
            filetype = "json",
            title = "jq",
            listed = true,
            output_qf = false,
            is_background_job = false,
        })
    end
    _G.jq_functions = jq_functions
    vim.cmd [[command! -nargs=* -range FJq :lua _G.jq_functions.filter_jq('<args>', "<line1>", "<line2>")]]
end

local build_functions = {}
function M.setup_build_function()
    build_functions.rebuild = function()
        local cmd = { "rebuild" }
        require('firvish.job_control').start_job({
            cmd = cmd,
            filetype = "job-output",
            title = "rebuild",
            listed = true,
            output_qf = true,
            is_background_job = true,
        })
    end
    _G.build_functions = build_functions
    vim.cmd [[command! Rebuild :lua _G.build_functions.rebuild()]]

    build_functions.azure_yaml = function(file)
        local cwd = os.getenv('PWD')
        local auth = os.getenv('AZURE_DEVOPS_AUTH')
        local ado_org = os.getenv('AZURE_DEVOPS_ORG')
        local ado_proj = os.getenv('AZURE_DEVOPS_PROJECT')
        local pipeline = os.getenv('AZURE_YAML_DEFINITION_ID')
        local branch = os.getenv('AZURE_YAML_BRANCH')

        local url = [[https://dev.azure.com/]] ..
            ado_org .. [[/]] .. ado_proj .. [[/_apis/pipelines/]] .. pipeline .. [[/preview?api-version=7.1-preview.1]]
        local auth_header = [[Authorization: Basic ]] .. auth
        local yaml_file = cwd .. "/" .. file

        local shell_script = string.format(
            [[yaml_string="
$(cat ${PWD}/${AZURE_YAML_DEBUG_SNIPPET})
$(cat %s)
"
yaml_string="$(echo "$yaml_string" | yq '... style="single"' - | sed -re /\s*\#.*$/d)"
curl -s -X POST '%s' -H 'Content-Type: application/json' -H '%s' --data-binary @- << THEEND | jq '.finalYaml // .' | yq '... style="double"' -
{
    "previewRun":true,
    "templateParameters": {},
    "resources": {
        "repositories": {
            "self": {
                "refName": "refs/heads/%s"
            }
        }
    },
    "yamlOverride":"$yaml_string"
}
THEEND]]     ,
            yaml_file, url, auth_header, branch, branch
        )
        local cmd = {
            "/bin/bash", "-c", shell_script
        }
        require('firvish.job_control').start_job({
            cmd = cmd,
            filetype = "yaml",
            title = "azureyaml",
            use_last_buffer = false,
            listed = true,
            output_qf = true,
            is_background_job = false,
            cwd = cwd
        })
    end
    vim.cmd [[command! -nargs=1 -complete=file AzureYaml :lua _G.build_functions.azure_yaml("<args>")]]
end

-- {{{ global lua debugging
_G.P = function(arg)
    print(vim.inspect(arg))
end

M.reload_package_complete = function(_, _, _)
    -- arg_lead, cmd_line, cursor_pos
    -- TODO: implement completion based on loaded packages
    return 'hi'
end

M.reload_packages_and_init = function()
    for name, _ in pairs(package.loaded) do
        if name:match('^vimrc') then
            package.loaded[name] = nil
        end
    end
    local reload_path = os.getenv("NVIM_RELOAD_PATH") or [[/home/mike/dotnix/neovim]]
    vim.opt.runtimepath:prepend({ reload_path, reload_path .. [[/lua]] })
    dofile(reload_path .. [[/init.lua]])
    vim.opt.runtimepath:remove({ reload_path, reload_path .. [[/lua]] })

    vim.notify("Reloaded vim", vim.log.levels.INFO)
end

M.reload_package = function(name)
    P([[name=]] .. name)
    if package.loaded[name] == nil then
        log_warning("Package not loaded.", "[vimrc]")
        return
    end
    package.loaded[name] = nil
    return require(name)
end

vim.cmd(
    [[command! LuaReload :lua require('vimrc').reload_packages_and_init()]]
)

M.activate_reload_on_write = function(name)
    vim.cmd([[augroup package_reload_]] .. name)
    vim.cmd([[au!]])
    vim.cmd([[au BufWritePost <buffer> ]]
        .. string.format([[:lua require('vimrc').reload_package('%s')]], name))
    vim.cmd([[augroup END]])
end

vim.cmd(
    [[command! -complete=custom,reloadpackage#complete -nargs=1 ActivateReload :lua require('vimrc').activate_reload_on_write(<q-args>)]]
)

-- }}}
-- {{{ syntax tools
M.print_synstack_at = function(line, col)
    local syn = vim.fn.synstack(line, col)
    for _, id in pairs(syn) do
        P(vim.fn.synIDattr(id, 'name'))
    end
end

vim.cmd(
    string.format("command! SyntaxInspect :lua require('vimrc').print_synstack_at(%s, %s)",
        vim.fn.line("."),
        vim.fn.col(".")
    )
)
-- }}}

return M
