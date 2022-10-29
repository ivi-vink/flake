local vim = vim
local cmd = vim.cmd
local fn = vim.fn

local M = {}
function M.setup(opts)
    local env_file = opts.env_file or ''
    local home = os.getenv('HOME')
    local user = os.getenv('USER')
    local cwd = opts.cwd or home
    P(cwd)

    local functions = {}

    functions.clean = function()
        require('firvish.job_control').start_job({
            cmd = {
                "docker",
                "run",
                "--interactive",
                "--rm",
                "--env-file",
                env_file,
                "--volume",
                cwd .. ":" .. cwd,
                "--workdir",
                cwd,
                "alpine/terragrunt",
                "/bin/sh",
                "-c",
                [[find ]] .. cwd .. [[ -type d -name .terragrunt-cache -prune -exec rm -rf {} \; &&]]
                .. [[find ]] .. cwd .. [[ -type f -name .terraform.lock.hcl -prune -exec rm -rf {} \;]]
            },
            filetype = "log",
            title = "clean",
            listed = true,
            output_qf = false,
            is_background_job = true
        })
    end

    functions.plan = function(terragrunt_path, dirty)
        if not dirty then
            functions.clean()
        end
        P(terragrunt_path)
        local cmd = {
                "docker",
                "run",
                "--interactive",
                "--rm",
                "--env-file",
                env_file,
                "--volume",
                cwd .. ":" .. cwd,
                "--workdir",
                cwd .. "/" .. terragrunt_path,
                "alpine/terragrunt",
                "terragrunt",
                "plan"
            }
        require('firvish.job_control').start_job({
            cmd = cmd,
            filetype = "log",
            title = "plan",
            listed = true,
            output_qf = true,
            is_background_job = false
        })
    end

    functions.apply = function(terragrunt_path, dirty)
        if not dirty then
            functions.clean()
        end
        local cmd = {
                "docker",
                "run",
                "--interactive",
                "--rm",
                "--env-file",
                env_file,
                "--volume",
                cwd .. ":" .. cwd,
                "--workdir",
                cwd .. "/" .. terragrunt_path,
                "alpine/terragrunt",
                "terragrunt",
                "apply",
                "--terragrunt-non-interactive",
                "--auto-approve"
            }
        require('firvish.job_control').start_job({
            cmd = cmd,
            filetype = "log",
            title = "plan",
            listed = true,
            output_qf = true,
            is_background_job = false
        })
    end

    functions.destroy = function(terragrunt_path, dirty)
        if not dirty then
            functions.clean()
        end
        local cmd = {
                "docker",
                "run",
                "--interactive",
                "--rm",
                "--env-file",
                env_file,
                "--volume",
                cwd .. ":" .. cwd,
                "--workdir",
                cwd .. "/" .. terragrunt_path,
                "alpine/terragrunt",
                "terragrunt",
                "destroy",
                "--terragrunt-non-interactive",
                "--auto-approve"
            }
        require('firvish.job_control').start_job({
            cmd = cmd,
            filetype = "log",
            title = "plan",
            listed = true,
            output_qf = true,
            is_background_job = false
        })
    end

    _G.terragrunt_functions = functions
    cmd [[command! -nargs=1 -complete=dir -bang TGplan :lua _G.terragrunt_functions.plan("<args>", "<bang>" ~= "!")]]
    cmd [[command! -nargs=1 -complete=dir -bang TGapply :lua _G.terragrunt_functions.apply("<args>", "<bang>" ~= "!")]]
    cmd [[command! -nargs=1 -complete=dir -bang TGdestroy :lua _G.terragrunt_functions.destroy("<args>", "<bang>" ~= "!")]]
    cmd [[command! TGclean :lua _G.terragrunt_functions.clean()]]

end
return M
