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
        buffer_setup(client)
    end

    -- lspconfig {{{
    local lspconfig = require('lspconfig')
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    -- always load lua lsp
    require('nlua.lsp.nvim').setup(lspconfig, {
        cmd = {
            Flake.lua_language_server .. "/bin/lua-language-server",
            "-E", Flake.lua_language_server .. "/share/lua-language-server/main.lua"
        },
        capabilities = capabilities,
        on_attach = buffer_setup_no_format,

        -- Include globals you want to tell the LSP are real :)
        globals = {
            -- Colorbuddy
            "Color", "c", "Group", "g", "s", "Flake",
        }
    })

    lspconfig.pyright.setup {
        root_dir = lspconfig.util.root_pattern(".git", vim.fn.getcwd()),
        on_attach = buffer_setup_no_format,
    }

    lspconfig.gopls.setup {
        before_init = function(params)
            params.processId = vim.NIL
        end,
        capabilities = capabilities,
        filetypes = { "go", "gomod", "gotmpl" },
        on_attach = buffer_setup_no_format,
        settings = {
            gopls = {
                experimentalPostfixCompletions = true,
                analyses = {
                    unusedparams = true,
                    shadow = true,
                },
                staticcheck = true,
            },
        },
        init_options = {
            usePlaceholders = true,
        }
    }

    lspconfig.yamlls.setup {
        schemas = {
            ["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.18.0-standalone-strict/all.json"] = "/*.k8s.yaml",
        },
        capabilities = capabilities,
        on_attach = function(client)
            buffer_setup_no_format(client)
            local bufnr = vim.api.nvim_get_current_buf()
            if vim.bo[bufnr].buftype ~= ""
                or vim.bo[bufnr].filetype == "helm" then
                vim.diagnostic.disable(bufnr)
                vim.defer_fn(function()
                    vim.diagnostic.reset(nil, bufnr)
                end, 1000)
            end
        end,
    }
    -- }}}

    local null_ls = require("null-ls")
    null_ls.setup({
        debug = vim.fn.expand("$VIMRC_NULL_LS_DEBUG") == "1",
        update_on_insert = false,
        on_attach = buffer_setup,
        sources = {
            -- nix linter: statix
            null_ls.builtins.code_actions.statix,
            null_ls.builtins.diagnostics.statix,
            null_ls.builtins.formatting.alejandra,
        }
    })
end

-- }}}

return M
-- vim: fdm=marker
