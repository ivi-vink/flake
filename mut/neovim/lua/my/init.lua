require("my.settings")
_G.P = function(...)
  vim.iter({...}):map(vim.inspect):each(print)
end
_G.ternary = function ( cond , T , F )
    if cond then return T else return F end
end
vim.cmd "colorscheme kanagawa-wave"

vim.cmd "filetype plugin on"
vim.cmd "filetype indent on"
vim.cmd "highlight WinSeparator guibg=None"
vim.cmd "packadd cfilter"

vim.api.nvim_set_hl(0, "VirtualTextWarning", {link= "Grey"})
vim.api.nvim_set_hl(0, "VirtualTextError", {link= "DiffDelete"})
vim.api.nvim_set_hl(0, "VirtualTextInfo", {link= "DiffChange"})
vim.api.nvim_set_hl(0, "VirtualTextHint", {link= "DiffAdd"})

local map = vim.keymap.set
local unmap = vim.keymap.del
function i_grep(word, file)
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(
      ":silent grep "
      .. ternary(not (word == ""), word .. " ", "")
      .. file:gsub("oil://", "")
      .. "<c-f>B<left>i<space>",
      true, false, true
    ),
    "n", false
  )
end

function cope()
  require("quicker").refresh()
  vim.cmd(":botright copen " .. math.floor(vim.o.lines / 2.1))
end

map("n", "gb", ":GBrowse<CR>")
map("n", "g<cr>", ":G<cr>")
map("n", "ge", function() vim.diagnostic.open_float() end)
-- (vim.diagnostic.config {:virtual_text false})
map("n", "-", ":Oil<cr>")
map("n", "<leader>qf", cope)
map("n", "<leader>q<BS>", ":cclose<cr>")
map("n", "<leader>ll", ":lopen<cr>")
map("n", "<leader>l<BS>", ":lclose<cr>")
map("n", "<M-h>", cope)
map("n", "<C-n>", ":cnext<cr>")
map("n", "<C-p>", ":cprev<cr>")
map("n", "<C-a>", ":Rerun<CR>")
map("n", "<C-s>", function()
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(
      ":Sh<up><c-f>",
      true, false, true
    ),
    "n", false
  )
  vim.schedule(function()
    vim.cmd("let v:searchforward = 0")
    map("n","/","/Sh.*",{buffer=true})
    map("n","?","?Sh.*",{buffer=true})
  end)
end)
map("n", "<C-x>", function()
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(
      ":Compile<up><c-f>",
      true, false, true
    ),
    "n", false
  )
  vim.schedule(function()
    vim.cmd("let v:searchforward = 0")
    map("n","/","/Compile.*",{buffer=true})
    map("n","?","?Compile.*",{buffer=true})
  end)
end)
map("n", "[q",":cprevious<cr>")
map("n", "]q",":cnext<cr>")
map("n", "[x",":lprevious<cr>")
map("n", "]x",":lnext<cr>")
map("n", "[g",":GV<cr>")
map("n", "]g",":GV?<cr>")
map("n", "]G",":GV!<cr>")
map("n", "<leader>:", function() i_grep("<c-r><c-w>", vim.fn.bufname("%")) end)
map("v", "<leader>:", ":Vgrep!<cr>")
map("n", "<leader>;", function() i_grep("", vim.fn.fnamemodify(vim.fn.bufname("%"), ":h")) end)
map("v", "<leader>;",  ":Vgrep<cr>")
map("n", "<leader>'", ":Find ")
map("n", "<leader>x<cr>", function() vim.cmd "b #" end)

require("nvim_comment").setup()

local oil_actions = require("oil.actions")
map("n", "_", oil_actions.open_cwd.callback)

local fzf = require("fzf-lua")
local action = (require "fzf-lua.actions")
fzf.setup {"max-perf"}
fzf.register_ui_select()
map("n", "<leader>xp", fzf.files)
map("n", "<leader>xa", fzf.args)
map("n", "<leader>x;", fzf.quickfix)
map("n", "<leader>xb", function()
  fzf.buffers({
    actions={default={fn=action.buf_edit_or_qf}}
  })
end)

local obsidian = require("obsidian")
obsidian.setup { workspaces = {
  { name =  "notes", path = ternary(vim.fn.isdirectory(vim.fn.expand("~/Sync/my/notes")) == 1, "~/Sync/my/notes",  "~/sync/my/notes")}
}}


vim.api.nvim_create_user_command(
  "Vgrep",
function(cmd)
  local buf, lrow, lcol = unpack(vim.fn.getpos("'<"))
  local buf, rrow, rcol = unpack(vim.fn.getpos("'>"))
  -- (local [line & rest] (vim.api.nvim_buf_get_text 0 (- <row 1) (- <col 1) (- >row 1) >col {}))
  local firstline =
     vim.iter(vim.api.nvim_buf_get_text(0, lrow-1, lcol-1, rrow-1, rcol, {}))
      :next()
  if cmd.bang then
    i_grep(firstline, vim.fn.bufname("%"))
  else
    i_grep(firstline, vim.fn.fnamemodify(vim.fn.bufname("%"), ":h"))
  end
end,
  {range= 1, bang=true}
)

vim.api.nvim_create_user_command(
  "NixEdit",
function(cmd)
  local f = io.popen("nix eval --raw /nix-config#nixosConfigurations." .. vim.fn.hostname() .. ".pkgs." .. cmd.args)
  vim.cmd("e " .. f:read())
end,
  {nargs=1}
)


local last_job_state = nil
local last_job_thunk = nil
local last_job_lines = ""
function qf(inputs, opts)
  local id, title = inputs.id, inputs.title
  local prettify = function(line)
    local l = line:gsub("%c+%[[0-9:;<=>?]*[!\"#$%%&'()*+,-./]*[@A-Z%[%]^_`a-z{|}~]*;?[A-Z]?", "")
    return l
  end
  local in_qf = function()
    return vim.opt_local.buftype:get() == "quickfix"
  end
  local is_at_last_line = function()
    local row, _ = vim.api.nvim_win_get_cursor(0)
    local last_line = vim.api.nvim_buf_line_count(0)
    return row == last_line
  end
  return function(lines)
    lines = vim.iter(lines):map(prettify):totable()
    vim.schedule(function()
      local what = {
        id=id,
        title=title,
        lines=lines,
        efm=opts.efm,
      }
      vim.fn.setqflist(
        {}, "a", what
      )
      if (not in_qf()) or (is_at_last_line() and in_qf()) then
        vim.cmd ":cbottom"
      end
    end)
  end
end

function qfjob(cmd, stdin, opts)
  last_job_lines = ""
  local opts = opts or {}
  opts.filter = opts.filter or (function(line)
    return line
  end)

  local title = table.concat(cmd, " ")
  vim.fn.setqflist({}, " ", {title=title})
  local append_lines = qf(vim.fn.getqflist({id=0,title=1}), opts)
  last_job_state = vim.system(
    cmd, {
      stdin=stdin,
      stdout=function(err,data)
        if data then
          if not opts.buffer then
            append_lines(vim.iter(data:gmatch("[^\n]+")):map(opts.filter))
          else
            last_job_lines = last_job_lines .. data
          end
        end
      end,
      stderr=function(err,data)
        if data then
          if not opts.buffer then
            append_lines(vim.iter(data:gmatch("[^\n]+")):map(opts.filter))
          else
            last_job_lines = last_job_lines .. data
          end
        end
      end,
    },
    function(job)
      vim.schedule(function()
        if opts.buffer then
            append_lines(vim.iter(last_job_lines:gmatch("[^\n]+")):map(opts.filter))
        end

        local winnr = vim.fn.winnr()
        if not (job.code == 0) then
          cope()
          if not (winnr == vim.fn.winnr()) then
            vim.notify([["]] .. title .. [[" failed!]])
            vim.cmd "wincmd p | cbot"
          end
        else
          if opts.open then
            cope()
          end
          vim.notify([["]] .. title .. [[" succeeded!]])
        end
      end)
    end)
end

vim.api.nvim_create_user_command(
  "Find",
  function(cmd)
    local bufs = vim.iter(vim.api.nvim_list_bufs())
      :fold({}, function(acc, b)
        acc[vim.api.nvim_buf_get_name(b)] = vim.api.nvim_buf_get_mark(b, [["]])
        return acc
      end)
    qfjob({ "fdfind", "--absolute-path", "--type", "f", "-E", vim.fn.expand("%:."), cmd.args }, nil, {efm = "%f:%l:%c:%m", open = true, filter = function(line)
      local pos = bufs[line] or {}
      local lnum, col = (pos[1] or "1"), (pos[2] or "0")
      return line .. ":" .. lnum .. ":" .. col .. ":" .. "hello"
    end})
  end,
  {nargs="*", bang=true, complete="file"})

function opts_for_args(args)
  local opts = {
    go = {
      test = function(cmd)
        return {buffer = true, efm=require('my.packages.go').efm()}
      end
    }
  }
  local arg_opts = vim.iter(args)
    :fold(opts, function(acc, v)
      if type(acc) == "table" and acc[v] then
        return acc[v]
      end
      return acc
    end)
  if type(arg_opts) == "function" then
    return arg_opts()
  elseif type(arg_opts) == "table" then
    return (arg_opts[1] or function() return {} end)()
  end
end

vim.api.nvim_create_user_command(
  "Sh",
  function(cmd)
    local thunk = function() qfjob({ "nu", "--commands", cmd.args }, nil, opts_for_args(cmd.fargs)) end
    last_job_thunk = thunk
    thunk()
  end,
  {nargs="*", bang=true, complete="shellcmd"})

vim.api.nvim_create_user_command(
  "Rerun",
  function(cmd)
    if not last_job_state then
      vim.notify "nothing to rerun"
    else
      if not last_job_state:is_closing() then
        vim.notify "Last job not finished"
      else
        last_job_thunk()
      end
    end
  end, {bang=true})

vim.api.nvim_create_user_command(
  "Stop",
  function()
    if last_job_state then
      last_job_state:kill()
      vim.notify "killed job"
    else
        vim.notify "nothing to do"
    end
  end, {bang=true})

local browse_git_remote = function(fugitive_data)
  local path = fugitive_data.path
  if not path then
    local bufname = vim.fn.bufname("%")
    if vim.startswith(bufname,"oil://")  then
      local d = "oil://" .. vim.fs.dirname(fugitive_data.git_dir) .. "/"
      path = bufname:sub(d:len()+1, bufname:len())
    end
  end
  assert(path)

  local home, org, project, repo = "", ""
  if vim.startswith(fugitive_data.remote, "git@") then
    home, repo = fugitive_data.remote:match("git@([^:]+):(.*)%.git")
    if not (home and repo) then
      home, org, project, repo = fugitive_data.remote:match("git@([^:]+):.*/(.*)/(.*)/(.*)")
    end
  end
  assert((home and org and project and repo) or (home and repo))
  P(home, org, project, repo)

  local homes = {
    ["ssh.dev.azure.com"] = "dev.azure.com",
  }
  if homes[home] then
    home = homes[home]
  end

  local urls = {
    ["bitbucket.org"] = {
      ["tree"] = function(home, org, project, repo)
        return "https://" .. home .. "/" .. repo .. "/src/" .. fugitive_data.commit .. "/" .. path
      end,
      ["blob"] = function(home, org, project, repo)
        return "https://" .. home .. "/" .. repo .. "/src/" .. fugitive_data.commit .. "/" .. path
      end,
      ["commit"] = function(home, org, project, repo)
        return "https://" .. home .. "/" .. repo .. "/commits/" .. fugitive_data.commit
      end,
      ["ref"] = function(home, org, project, repo)
        return "https://" .. home .. "/" .. repo .. "/commits/" .. fugitive_data.commit
      end,
    },
    ["dev.azure.com"] = {
      ["tree"] = function(home, org, project, repo)
        return "https://" .. home .. "/" .. org .. "/" .. project .. "/_git/" .. repo .. "?version=GB" .. fugitive_data.commit .. "&path=/" .. path
      end,
      ["blob"] = function(home, org, project, repo)
        return "https://" .. home .. "/" .. org .. "/" .. project.. "/_git/" .. repo .. "?version=GB" .. fugitive_data.commit .. "&path=/" .. path
      end,
      ["commit"] = function(home, org, project, repo)
        return "https://" .. home .. "/" .. org .. "/" .. project.. "/_git/" .. repo .. "/commit/" .. fugitive_data.commit
      end,
      ["ref"] = function(home, org, project, repo)
        return "https://" .. home .. "/" .. org .. "/" .. project.. "/_git/" .. repo .. "/commit/" .. fugitive_data.commit
      end,
    },
    ["gitlab.com"] = {
      ["tree"] = function(home, org, project, repo)
        return "https://" .. home .. "/" .. repo .. "/-/tree/" .. fugitive_data.commit .. "/" .. path
      end,
      ["blob"] = function(home, org, project, repo)
        return "https://" .. home .. "/" .. repo .. "/-/blob/" .. fugitive_data.commit .. "/" .. path
      end,
      ["commit"] = function(home, org, project, repo)
        return "https://" .. home .. "/" .. repo .. "/-/commit/" .. fugitive_data.commit
      end,
      ["ref"] = function(home, org, project, repo)
        return "https://" .. home .. "/" .. repo .. "/-/commit/" .. fugitive_data.commit
      end,
    },
    ["github.com"] = {
      ["tree"] = function(home, org, project, repo)
        return "https://" .. home .. "/" .. repo .. "/tree/" .. fugitive_data.commit .. "/" .. path
      end,
      ["blob"] = function(home, org, project, repo)
        return "https://" .. home .. "/" .. repo .. "/blob/" .. fugitive_data.commit .. "/" .. path
      end,
      ["commit"] = function(home, org, project, repo)
        return "https://" .. home .. "/" .. repo .. "/commit/" .. fugitive_data.commit
      end,
      ["ref"] = function(home, org, project, repo)
        return "https://" .. home .. "/" .. repo .. "/commit/" .. fugitive_data.commit
      end,
    },
  }

  return urls[home][fugitive_data.type](home, org, project, repo)
end
vim.g.fugitive_browse_handlers = { browse_git_remote }

-- require("lsp_signature").setup()
require("nvim-treesitter.configs").setup({highlight =  {enable = true}})
require("gitsigns").setup({
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'right_align', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
    virt_text_priority = 100,
    use_focus = true,
  },
})

vim.opt.clipboard:append({"unnamedplus"})

local osc52 = require("vim.ui.clipboard.osc52")

function paste()
  return {
    vim.fn.split(vim.fn.getreg(""), "\n"),
    vim.fn.getregtype("")
  }
end
function xclip(lines)
  vim.system({ "nu", "--commands", "xclip -f -sel c | xclip"}, {stdin=lines, text=true}, nil)
end
vim.g.clipboard = {
  name = "OSC 52",
  copy =  {
    ["+"] = xclip, ["*"] = xclip
  },
  paste = {
    ["+"] = paste, ["*"] = paste
  }
}
require("my.events")
require("my.packages")

-- require('render-markdown').setup ({
--       opts = {
--         file_types = { "markdown", "Avante" },
--       },
--       ft = { "markdown", "Avante" },})
-- require('avante_lib').load()
-- -- require('copilot').setup {}
-- require('avante').setup ({
--   provider = "openai",
--   openai = {
--     model = "gpt-4o",
--   },
--   behaviour = {
--     auto_suggestions = false,
--     auto_set_highlight_group = true,
--     auto_set_keymaps = true,
--     auto_apply_diff_after_generation = false,
--     support_paste_from_clipboard = false,
--   },
--   mappings = {
--     --- @class AvanteConflictMappings
--     diff = {
--       ours = "co",
--       theirs = "ct",
--       all_theirs = "ca",
--       both = "cb",
--       cursor = "cc",
--       next = "]x",
--       prev = "[x",
--     },
--     suggestion = {
--       accept = "<M-l>",
--       next = "<M-]>",
--       prev = "<M-[>",
--       dismiss = "<C-]>",
--     },
--     jump = {
--       next = "]]",
--       prev = "[[",
--     },
--     submit = {
--       normal = "<CR>",
--       insert = "<C-s>",
--     },
--     sidebar = {
--       apply_all = "A",
--       apply_cursor = "a",
--       switch_windows = "<Tab>",
--       reverse_switch_windows = "<S-Tab>",
--     },
--   },
-- })

require("quicker").setup({
  keys = {
    {
      ">",
      function()
        require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
      end,
      desc = "Expand quickfix context",
    },
    {
      "<",
      function()
        require("quicker").collapse()
      end,
      desc = "Collapse quickfix context",
    },
  },
})
-- (local
--  draw
--  (fn [toggle]
--    (if
--      toggle
--      (do
--        (vim.cmd "set virtualedit=all")
--        (vim.keymap.set :v "<leader>;" "<esc>:VBox<CR>")
--        (vim.keymap.set "n" "J" "<C-v>j:VBox<CR>")
--        (vim.keymap.set "n" "K" "<C-v>k:VBox<CR>")
--        (vim.keymap.set "n" "L" "<C-v>l:VBox<CR>")
--        (vim.keymap.set "n" "H" "<C-v>h:VBox<CR>"))
--      (do
--        (vim.cmd "set virtualedit=")
--        (vim.keymap.del :v "<leader>;")
--        (vim.keymap.del "n" "J")
--        (vim.keymap.del "n" "K")
--        (vim.keymap.del "n" "L")
--        (vim.keymap.del "n" "H")))))
