local vim = vim
local cmd = vim.cmd
local fn = vim.fn

local M = {}
function M.setup(opts)
    assert(opts.release_name, "release name is required. ")
    assert(opts.chart_dir, "chartdir is required. ")
    assert(opts.docker_dir, "docker_dir is required. ")
    assert(opts.docker_tag, "docker_tag is required. ")

    local values_files = opts.values_files or {}
    local values_sets = opts.values_sets or {}
    local cluster = opts.cluster or "so"

    local dependency_update = ""
    if opts.dependency_update then
        dependency_update = "--dependency-update"
    end

    table.insert(values_sets, "envshort=" .. cluster)
    table.insert(values_sets, "cluster=" .. cluster)
    table.insert(values_sets, "clusterHost=" .. cluster .. ".stater.com")

    local functions = {}
    functions.helm_upgrade = function(output_qf)
        local cmd = {
                "helm",
                "upgrade",
                "--install",
                "--values",
                string.join(values_files, ","),
                opts.release_name,
                "."
            }
        require('firvish.job_control').start_job({
            cmd = cmd,
            filetype = "log",
            title = "upgrade",
            listed = true,
            output_qf = output_qf,
            is_background_job = true,
            cwd = opts.chart_dir,
        })
    end

    functions.helm_delete = function(output_qf)
        require('firvish.job_control').start_job({
            cmd = {
                "helm",
                "delete",
                opts.release_name,
            },
            filetype = "log",
            title = "delete",
            listed = true,
            output_qf = output_qf,
            is_background_job = true,
            cwd = opts.chart_dir,
        })
    end

    functions.helm_build = function(output_qf)
            local cmd = {
                "/bin/sh",
                "-c",
                string.format(
                [[if docker build -t %s %s && ]] ..
                [[docker push %s ; then ]] ..
                [[helm delete %s ; ]] ..
                [[helm upgrade --install %s --values %s --set %s %s . ; fi]],
                opts.docker_tag,
                opts.docker_dir,
                opts.docker_tag,
                opts.release_name,
                dependency_update,
                string.join(values_files, ","),
                string.join(values_sets, ","),
                opts.release_name
                )
            }
        P(cmd)
        require('firvish.job_control').start_job({
            cmd = cmd,
            filetype = "log",
            title = "delete",
            listed = true,
            output_qf = output_qf,
            is_background_job = true,
            cwd = opts.chart_dir,
        })
    end

    functions.helm_debug = function(update_remote)
        local cmd = {
            "helm",
            "template",
            "--debug",
            "--values",
            string.join(values_files, ","),
            "--set",
            string.join(values_sets, ","),
            opts.release_name,
            "."
        }
        P(cmd)
        if update_remote then
            table.insert(cmd, 3, "--dependency-update")
        end
        require('firvish.job_control').start_job({
            cmd = cmd,
            filetype = "log",
            title = "delete",
            listed = true,
            output_qf = false,
            is_background_job = false,
            cwd = opts.chart_dir,
        })
    end

    _G.helm_functions = functions
    cmd [[command! -bang HelmPut :lua _G.helm_functions.helm_upgrade("<bang>" ~= "!")]]
    cmd [[command! -bang HelmDelete :lua _G.helm_functions.helm_delete("<bang>" ~= "!")]]

    cmd [[command! -bang HelmBuild :lua _G.helm_functions.helm_build("<bang>" ~= "!")]]
    cmd [[command! -bang HelmBug :lua _G.helm_functions.helm_debug("<bang>" ~= "!")]]

end
return M
