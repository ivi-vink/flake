local vim = vim
local cmd = vim.cmd
local fn = vim.fn

local M = {}
function M.setup(opts)
    P(opts)
    local home = os.getenv('HOME')
    local user = os.getenv('USER')
    assert(opts.cwd, "cwd is required. ")
    assert(opts.inventory, "inventory is required. ")
    -- This needs to be built on the machine you use it due to requiring the user to be present in the /etc/passwd table.
    local functions = {}
    local secrets_exist = fn.filereadable(fn.expand(opts.vault_file)) == 1
    local vars_files = ""
    if secrets_exist then
        vars_files = vars_files .. [[
  vars_files:
    - ]] .. opts.vault_file .. "\n"
    end
    functions.ansible_dump = function(output_qf)
        local cmd = {
                "docker",
                "run",
                "--interactive",
                "--rm",
                "--network=host",
                "--user=" .. user,
                "-e",
                "HOME=" .. home,
                "--volume=" .. home .. ":" .. home,
                "--workdir=" .. opts.cwd,
                "mvinkio/ansible",
                "/bin/bash",
                "-c",
[[cat <<EOF > dev-plabook.yaml
---
- name: dump all
  hosts: all
]]
..
vars_files
..
[[
  tasks:
    - name: Print vars
      debug:
        var: vars
    - name: Print environment
      debug:
        var: environment
    - name: Print group_names
      debug:
        var: group_names
    - name: Print groups
      debug:
        var: groups
    - name: Print hostvars
/      debug:
        var: hostvars
EOF]] ..
"\n ansible-playbook -vvv -i " .. opts.inventory .. " dev-plabook.yaml "
            }
        P(cmd)
        require('firvish.job_control').start_job({
            cmd = cmd,
            filetype = "log",
            title = "dump",
            listed = true,
            output_qf = false,
            is_background_job = false,
        })
    end

    functions.ansible_run = function (playbook, debug)
        P(playbook)
        P(debug)
        local set_debug = ""
        if debug then
            set_debug = "ANSIBLE_ENABLE_TASK_DEBUGGER=True"
        end
        local run_cmd = set_debug ..
            [[ ansible-playbook ]] ..
            [[-v ]] ..
            [[-i ]] .. opts.inventory .. [[ ]] ..
            playbook
        local job_cmd = {
                "docker",
                "run",
                "--interactive",
                "--rm",
                "--network=host",
                "--user=" .. user,
                "-e", "HOME=" .. home,
                "-e", "USER=" .. user,
                "--volume=" .. home .. ":" .. home,
                "--workdir=" .. opts.cwd,
                "mvinkio/ansible",
                "/bin/bash",
                "-c",
                run_cmd
            }
        local interactive_cmd = {
                "docker",
                "run",
                "--interactive",
                "--tty",
                "--rm",
                "--network=host",
                "--user=" .. user,
                "-e",
                "HOME=" .. home,
                "-e",
                "USER=" .. user,
                "--volume=" .. home .. ":" .. home,
                "--workdir=" .. opts.cwd,
                "mvinkio/ansible",
                "/bin/bash",
                "-c"
            }
        if not debug then
            P(job_cmd)
            require('firvish.job_control').start_job({
                cmd = job_cmd,
                filetype = "log",
                title = "ansiblejob",
                listed = true,
                output_qf = false,
                is_background_job = false,
            })
        else
            local term_cmd = [[sp | term /bin/bash -c ']] .. table.concat(interactive_cmd, ' ') .. [[ "]] .. run_cmd .. [["']]
            P(term_cmd)
            vim.cmd(term_cmd)
        end
    end

    functions.install_requirements = function (bang)
        local cmd = {
                "docker",
                "run",
                "--interactive",
                "--rm",
                "--network=host",
                "--user=" .. user,
                "-e", "HOME=" .. home,
                "--volume=" .. home .. ":" .. home,
                "--workdir=" .. opts.cwd,
                "mvinkio/ansible",
                "/bin/bash",
                "-c",
                "ansible-galaxy install -r " .. opts.ansible_galaxy_requirements
            }
        P(cmd)
        require('firvish.job_control').start_job({
            cmd = cmd,
            filetype = "log",
            title = "ansiblejob",
            listed = true,
            output_qf = false,
            is_background_job = false,
        })
    end

    functions.ansible_session = function (bang)
        local interactive_cmd = {
                "docker",
                "run",
                "--interactive",
                "--tty",
                "--rm",
                "--network=host",
                "--user=" .. user,
                "-e",
                "USER=" .. user,
                "-e",
                "HOME=" .. home,
                "--volume=" .. home .. ":" .. home,
                "--workdir=" .. opts.cwd,
                "mvinkio/ansible",
                "/bin/bash"
            }
        local term_cmd = [[sp | term ]] .. table.concat(interactive_cmd, ' ')
        P(term_cmd)
        vim.cmd(term_cmd)
    end

    _G.ansible_functions = functions
    cmd [[command! -bang AnsibleBug :lua _G.ansible_functions.ansible_dump("<bang>" ~= "!")]]
    cmd [[command! -complete=file -nargs=1 -bang AnsiblePlaybook :lua _G.ansible_functions.ansible_run("<args>", "<bang>" == "!")]]
    cmd [[command! -bang AnsibleGalaxyRequirements :lua _G.ansible_functions.install_requirements("<bang>" ~= "!")]]
    cmd [[command! -bang AnsibleSession :lua _G.ansible_functions.ansible_session("<bang>" ~= "!")]]

end
return M
