local M = {}

function M.setup(opts)
    -- assert(opts.org_url, "org url is required. ")
    -- assert(opts.pipeline_id, "pipeline id is required. ")
    -- assert(opts.api_version, "api version is required. ")
    -- assert(opts.basic_auth_token, "basic auth token is required. ")

    -- local functions = {}
    -- functions.pipeline_bug = function(output_qf)
    --     local cmd = {
    --             "/bin/sh",
    --             "-c",
    --             [[curl -sSL --compressed -X POST -H ]] ..
    --             [['Authorization: Basic ]] .. opts.basic_auth_token .. [[' ]] ..
    --             [[-H 'Content-Type: application/json' ]] ..
    --             [[--data-raw "{ \"previewRun\": true }" ]] ..
    --             opts.org_url .. "/_apis/pipelines/" .. opts.pipeline_id .. "/preview?api-version=" .. opts.api_version ..
    --             " | jq .finalYaml | xargs -0 printf %b | sed -e 's@^\"@@' -e 's@\"$@@'"
    --         }
    --     P(cmd)
    --     require('firvish.job_control').start_job({
    --         cmd = cmd,
    --         filetype = "log",
    --         title = "pipeline",
    --         listed = true,
    --         output_qf = output_qf,
    --         is_background_job = false,
    --         cwd = opts.chart_dir,
    --     })
    -- end

    -- _G.azure_functions = functions

    -- cmd [[command! -bang PipelineBug :lua _G.azure_functions.pipeline_bug("<bang>" ~= "!")]]

end

return M
