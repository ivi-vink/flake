local utils = require 'vimrc.utils'
local M = {}

-- TODO: parameterise
-- TODO: extend stuff later

M.client_log = {}

-- local functions {{{
local function on_publish_diagnostics(_, result, ctx, config)
    vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
    vim.diagnostic.setloclist({
        open = false
    })
end

local function setup_handlers(client, _)
    client.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(on_publish_diagnostics, {
        virtual_text = false,
        underline = true,
        update_in_insert = false,
        severity_sort = true
    })
end

local function setup_server_capabilities_maps(client, bufnr)
    local map = vim.api.nvim_buf_set_keymap
    local opts = { silent = true, noremap = true }
    local capabilities = client.server_capabilities

    if capabilities.completion ~= false then
        vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
    end

    if capabilities.hover ~= false then
        vim.api.nvim_buf_set_option(bufnr, "keywordprg", ":LspHover")
    end

    if capabilities.rename == true then
        map(bufnr, "n", "<leader>gr", "<Cmd>lua vim.lsp.buf.rename()<CR>", opts)
    end

    if capabilities.signature_help == true then
        map(bufnr, "n", "<leader>gs", "<Cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    end

    if capabilities.goto_definition ~= false then
        map(bufnr, "n", "<leader>gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
    end

    if capabilities.declaration == true then
        map(bufnr, "n", "<leader>gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    end

    if capabilities.implementation == true then
        map(bufnr, "n", "<leader>gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    end

    if capabilities.find_references ~= false then
        map(bufnr, "n", "<leader>gg", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
    end

    map(bufnr, "n", "<leader>ge", "<cmd>lua require'vimrc.lsp'.line_diagnostic()<CR>", opts)

    if capabilities.document_symbol ~= false then
        map(bufnr, "n", "<leader>gds", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", opts)
    end

    if capabilities.workspace_symbol ~= true then
        map(bufnr, "n", "<leader>gw", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>", opts)
    end

    if capabilities.code_action ~= false then
        map(bufnr, "n", "<leader>ga", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    end

    if capabilities.documentFormattingProvider == true then
        vim.api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.format()")
        map(bufnr, "n", "<leader>gq", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", opts)
    end

    if capabilities.document_range_formatting == true then
        map(bufnr, "v", "<leader>gq", "<Esc><Cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
    end

    if capabilities.hover ~= false then
        vim.api.nvim_command("command! -buffer -nargs=1 LspHover lua vim.lsp.buf.hover()<CR>")
    end
end

-- }}}

-- diagnostics {{{
function M.line_diagnostic()
    local line = vim.fn.line('.') - 1
    local diags = vim.diagnostic.get(0, {
        lnum = line
    })
    for _, diag in ipairs(diags) do
        utils.log_warning(diag.message, diag.source)
    end
end

-- }}}

-- setup {{{
function M.setup()

    local buffer_setup = function(client)
        table.insert(M.client_log, client)
        local bufnr = vim.api.nvim_get_current_buf()

        setup_server_capabilities_maps(client, bufnr)
        setup_handlers(client, bufnr)
        require("lsp_signature").on_attach({
            bind = true,
            floating_window = false,
            toggle_key = "<C-g><C-s>",
            extra_trigger_chars = { "{", "}" },
            hint_prefix = "@ ",
            check_pumvisible = false
        }, bufnr)
    end

    local buffer_setup_no_format = function(client)
        client.server_capabilities.document_formatting = false
        buffer_setup(client)
    end

    -- lspconfig {{{
    local lspconfig = require 'lspconfig'
    -- check if docker is executable first?
    local runtime_path = vim.split(package.path, ';')
    table.insert(runtime_path, "lua/?.lua")
    table.insert(runtime_path, "lua/?/init.lua")

    -- always load lua lsp
    require('nlua.lsp.nvim').setup(require('lspconfig'), {
      cmd = { "/lsp/bin/lua-language-server", "-E", "/lsp/main.lua" },
      on_attach = buffer_setup_no_format,

      -- Include globals you want to tell the LSP are real :)
      globals = {
        -- Colorbuddy
        "Color", "c", "Group", "g", "s",
      }
    })

    -- lspconfig.sumneko_lua.setup {
    --     filetypes = { "lua" },
    --     on_attach = buffer_setup_no_format,
    --     settings = {
    --         Lua = {
    --             completion = {
    --                 keywordSnippet = "Disable",
    --                 showWord = "Disable",
    --             },
    --             diagnostics = {
    --                 enable = true,
    --                 globals = vim.list_extend({
    --                     -- Neovim
    --                     "vim",
    --                     -- Busted
    --                     "describe", "it", "before_each", "after_each", "teardown", "pending", "clear"
    --                 }, {})
    --             },
    --             runtime = {
    --                 version = "LuaJIT",
    --             },
    --             workspace = {
    --                 vim.list_extend(get_lua_runtime(), {}),
    --                 maxPreload = 10000,
    --                 preloadFileSize = 10000,
    --             },
    --         }
    --     }
    -- }

    -- out = vim.fn.system('docker images -q mvinkio/azure-pipelines-lsp')
    -- if string.len(out) ~= 0 then
    --     lspconfig.yamlls.setup {
    --         before_init = function(params)
    --             params.processId = vim.NIL
    --         end,
    --         on_new_config = function(new_config, new_root_dir)
    --             new_config.cmd = {
    --                 "node",
    --                 new_root_dir,
    --                 home .. "/projects/devops-pipelines/node_modules/azure-pipelines-language-server/out/server.js",
    --                 "--stdio"
    --             }
    --         end,
    --         filetypes = { "yaml" },
    --         root_dir = lspconfig.util.root_pattern(".git", vim.fn.getcwd()),
    --         on_attach = buffer_setup_no_format,
    --         settings = {
    --             yaml = {
    --                 format = {
    --                     enable = true
    --                 },
    --                 schemas = {
    --                     [home .. "/projects/devops-pipelines/schema"] = "/*"
    --                 },
    --                 validate = true
    --             }
    --         }
    --     }
    -- else
    --     utils.log_warning("No image mvinkio/azure-pipelines-lsp.", "vimrc/lsp", true)
    -- end

    local out = vim.fn.system('docker images -q mvinkio/python')
    if string.len(out) ~= 0 then
        lspconfig.pyright.setup {
            cmd = {
                "docker",
                "run",
                "--rm",
                "--env-file=" .. vim.fn.getcwd() .. "/.env",
                "--interactive",
                "--workdir=" .. vim.fn.getcwd(),
                "--volume=" .. vim.fn.getcwd() .. ":" .. vim.fn.getcwd(),
                "mvinkio/python",
                "pyright-langserver", "--stdio"
            },
            on_new_config = function(new_config, new_root_dir)
                new_config.cmd = {
                    "docker",
                    "run",
                    "--rm",
                    "--env-file=" .. new_root_dir .. "/.env",
                    "--interactive",
                    "--workdir=" .. new_root_dir,
                    "--volume=" .. new_root_dir .. ":" .. new_root_dir,
                    "mvinkio/python",
                    "pyright-langserver", "--stdio"
                }
            end,
            filetypes = { "python" },
            root_dir = lspconfig.util.root_pattern(".git", vim.fn.getcwd()),
            on_attach = buffer_setup_no_format,
        }
    else
        utils.log_warning("No image mvinkio/python.", "vimrc/lsp", true)
    end

    out = vim.fn.system('docker images -q mvinkio/go')
    if string.len(out) ~= 0 then
        lspconfig.gopls.setup {
            before_init = function(params)
                params.processId = vim.NIL
            end,
            on_new_config = function(new_config, new_root_dir)
                new_config.cmd = {
                    "docker",
                    "run",
                    "--rm",
                    "--interactive",
                    "-e=GOPROXY=https://proxy.golang.org",
                    "-e=GOOS=linux",
                    "-e=GOARCH=amd64",
                    "-e=GOPATH=" .. new_root_dir .. "/go",
                    "-e=GOCACHE=" .. new_root_dir .. "/.cache/go-build",
                    "--workdir=" .. new_root_dir,
                    "--volume=" .. new_root_dir .. ":" .. new_root_dir,
                    "--network=bridge",
                    "mvinkio/go",
                    "gopls"
                }
            end,
            -- cmd = { "docker", "run", "--rm", "-i", "-v", home .. ":" .. home, "mvinkio/gopls" },
            filetypes = { "go", "gomod", "gotmpl" },
            on_attach = buffer_setup_no_format,
        }
    else
        utils.log_warning("No image mvinkio/go.", "vimrc/lsp", true)
    end

    -- out = vim.fn.system('docker images -q mvinkio/sveltels')
    -- if string.len(out) ~= 0 then
    --     lspconfig.svelte.setup {
    --         before_init = function(params)
    --             params.processId = vim.NIL
    --         end,
    --         cmd = {
    --             "docker",
    --             "run",
    --             "--rm",
    --             "--interactive",
    --             "--volume=" .. home .. ":" .. home,
    --             "--network=none",
    --             "mvinkio/sveltels"
    --         },
    --         on_attach = buffer_setup,
    --     }
    -- else
    --     utils.log_warning("No image mvinkio/sveltels.", "vimrc/lsp", true)
    -- end

    -- }}}

    local null_ls = require("null-ls")
    local my_black = null_ls.builtins.formatting.black.with({
        filetypes = { "python" },
        command = "black",
        args = { "$FILENAME" }
    })
    null_ls.setup({
        debug = vim.fn.expand("$VIMRC_NULL_LS_DEBUG") == "1",
        update_on_insert = false,
        on_attach = buffer_setup,
        sources = {
            my_black,
            null_ls.builtins.completion.luasnip
        }
    })
end

-- }}}

return M
-- vim: fdm=marker
