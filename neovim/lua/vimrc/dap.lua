local vim = vim
local cmd = vim.cmd
local api = vim.api
local M = {}

local function register_debug_adapters(cwd)
    local dap = require 'dap'
    local python_args = {
        "run",
        "--rm",
        "--volume=/var/run/docker.sock:/var/run/docker.sock",
        "--interactive",
        "--env-file=" .. cwd .. "/.env",
        "--volume", cwd .. ":" .. cwd,
        "--network=host",
        "mvinkio/python",
        "python", "-m", "debugpy.adapter"
    }
    dap.adapters.python = {
        type = 'executable',
        command = "docker",
        args = python_args,
    }

    dap.adapters.go = function(callback, _)
        -- _ config
        local stdout = vim.loop.new_pipe(false)
        local stderr = vim.loop.new_pipe(false)
        local handle
        local pid_or_err
        local port = 38697

                    -- "docker",
                    -- "run",
                    -- "--rm",
                    -- "--interactive",
                    -- "-e=GOPROXY=https://proxy.golang.org",
                    -- "-e=GOOS=linux",
                    -- "-e=GOARCH=amd64",
                    -- "-e=GOPATH=" .. new_root_dir .. "/go",
                    -- "-e=GOCACHE=" .. new_root_dir .. "/.cache/go-build",
                    -- "--workdir=" .. new_root_dir,
                    -- "--volume=" .. new_root_dir .. ":" .. new_root_dir,
                    -- "--network=bridge",
                    -- "mvinkio/go",
                    -- "gopls"
        local opts = {
            stdio = { nil, stdout },
            args = { "run",
                "-i", "--rm",
                "--security-opt=seccomp:unconfined",
                "--volume=/var/run/docker.sock:/var/run/docker.sock",
                "--env-file=" .. cwd .. "/.env",
                "-e=GOPROXY=https://proxy.golang.org",
                "-e=GOOS=linux",
                "-e=GOARCH=amd64",
                "-e=GOPATH=" .. cwd .. "/go",
                "-e=GOCACHE=" .. cwd .. "/.cache/go-build",
                "-v", cwd .. ":" .. cwd, -- TODO: use os.getenv here
                "-w", cwd, -- TODO: use find root here
                "--network", "host",
                "mvinkio/go",
                "dlv", "dap", "-l", "127.0.0.1:" .. port,
                "--only-same-user=false",
                "--log",
            },
            detached = false
        }
        handle, pid_or_err = vim.loop.spawn("docker", opts, function(code)
            stdout:close()
            stderr:close()
            handle:close()
            if code ~= 0 then
                print('dlv exited with code', code)
            end
        end)
        assert(handle, 'Error running dlv: ' .. tostring(pid_or_err))
        stdout:read_start(function(err, chunk)
            assert(not err, err)
            if chunk then
                P(chunk)
                vim.schedule(function()
                    require('dap.repl').append(chunk)
                end)
            end
        end)
        stderr:read_start(function(err, chunk)
            assert(not err, err)
            if chunk then
                P(chunk)
            end
        end)
        -- Wait for delve to start
        vim.defer_fn(
            function()
                callback({ type = "server", host = "127.0.0.1", port = port })
            end,
            2000)
    end

end

local function set_configurations()
    local dap = require 'dap'
    dap.configurations.python = {
        {
            -- The first three options are required by nvim-dap
            type = 'python'; -- the type here established the link to the adapter definition: `dap.adapters.python`
            request = 'launch';
            name = "Launch file";

            -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

            program = "${file}"; -- This configuration will launch the current file if used.
            -- TODO: use container for python interpreter
            -- pythonPath = function()
            --   -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
            --   -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
            --   -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
            --   local cwd = vim.fn.getcwd()
            --   if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
            --     return cwd .. '/venv/bin/python'
            --   elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
            --     return cwd .. '/.venv/bin/python'
            --   else
            --     return '/usr/bin/python'
            --   end
            -- end;
        },
    }

    -- docker run --rm -i -v /home/mike:/home/mike --network=host -w /home/mike/projects/example/hello mvinkio/godap dap -l 127.0.0.1:38697 --log --log-output="dap" --only-same-user=false

    dap.configurations.go = {
        {
            type = "go",
            name = "Debug",
            request = "launch",
            program = "${file}"
        },
        {
            type = "go",
            name = "Debug test", -- configuration for debugging test files
            request = "launch",
            mode = "test",
            program = vim.fn.fnamemodify(vim.fn.expand('%'),':p:h')
        },
        -- works with go.mod packages and sub packages
        {
            type = "go",
            name = "Debug test (go.mod)",
            request = "launch",
            mode = "test",
            program = "./${relativeFileDirname}"
        }
    }
    local set_go_keymaps = function()
        vim.keymap.set(
            "n",
            "<leader>df",
            [[<cmd>lua require'vimrc.dap'.continue(require'dap'.configurations.go[1])<CR>]],
            { noremap = true }
        )
        vim.keymap.set(
            "n",
            "<leader>df",
            [[<cmd>lua require'vimrc.dap'.continue(require'dap'.configurations.go[1])<CR>]],
            { noremap = true }
        )
    end
    local augroup = api.nvim_create_augroup("vimrc_go_dap_config", { clear = true })
    api.nvim_create_autocmd("FileType", { pattern = "go", callback = set_go_keymaps, group = augroup })

end

local function set_keymaps()
    local map = vim.api.nvim_set_keymap
    -- taken from: https://github.com/Furkanzmc/dotfiles/blob/master/vim/lua/vimrc/dap.lua
    -- version: 9561e7c700e0ffe74cf9fd61a0e4543ae14938c6
    map("n", "<leader>dc", ":lua require'vimrc.dap'.continue()<CR>", { silent = true, noremap = true })
    map("n", "<leader>dt", ":lua require'dap'.close()<CR>", { silent = true, noremap = true })
    map("n", "<leader>ds", ":lua require'dap'.step_into()<CR>", { silent = true, noremap = true })

    map("n", "<leader>dk", ":lua require('dapui').eval()<CR>", { silent = true, noremap = true })
    map("v", "<leader>dk", ":lua require('dapui').eval()<CR>", { silent = true, noremap = true })
    map("n", "<leader>do", ":lua require'dap'.step_out()<CR>", { silent = true, noremap = true })

    map("n", "<leader>dn", ":lua require'dap'.step_over()<CR>", { silent = true, noremap = true })
    map("n", "<leader>du", ":lua require'dap'.up()<CR>", { silent = true, noremap = true })
    map("n", "<leader>dd", ":lua require'dap'.down()<CR>", { silent = true, noremap = true })

    map(
        "n",
        "<leader>db",
        ":lua require'dap'.toggle_breakpoint()<CR>",
        { silent = true, noremap = true }
    )
    map(
        "n",
        "<leader>dbc",
        ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
        { silent = true, noremap = true }
    )
    map(
        "n",
        "<leader>dbl",
        ":lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>",
        { silent = true, noremap = true }
    )

    map("n", "<leader>dui", ":lua require'dapui'.toggle()<CR>", { silent = true, noremap = true })
    map("n", "<leader>dr", ":lua require'dap'.run_to_cursor()<CR>", { silent = true, noremap = true })
    map(
        "n",
        "<leader>dl",
        ":lua require'dap'.list_breakpoints(true)<CR>",
        { silent = true, noremap = true }
    )
    -- map(
    --     "n",
    --     "<leader>dp",
    --     ":lua require'dap.ui.variables'.scopes()<CR>",
    --     { silent = true, noremap = true }
    -- )
end

local function set_commands()
    cmd([[command! DapUIOpen :lua require'dapui'.open()]])
    cmd([[command! DapUIClose :lua require'dapui'.close()]])
end

function M.continue(config)
    local dap = require 'dap'
    register_debug_adapters(vim.fn.getcwd())
    set_configurations()
    if config then
        dap.run(config)
    else
        dap.continue()
    end
end

function M.setup_dap()
    if vim.o.loadplugins == false then
        return
    end

    cmd([[packadd nvim-dap]])
    cmd([[packadd nvim-dap-ui]])

    local vim_startup_dir = vim.fn.getcwd()
    register_debug_adapters(vim_startup_dir)
    set_configurations()

    cmd [[augroup vimrc_dap]]
    cmd [[au!]]
    cmd [[au FileType dap-repl lua require('dap.ext.autocompl').attach()]]
    cmd [[augroup END]]

    -- Commands and keymaps
    require('dapui').setup()
    set_keymaps()
    set_commands()
end

return M
