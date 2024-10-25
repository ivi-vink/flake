require("my.settings")
_G.P = function(...)
  vim.iter({...}):map(vim.inspect):each(print)
end
_G.ternary = function ( cond , T , F )
    if cond then return T else return F end
end
vim.cmd "colorscheme kanagawa-wave"

vim.cmd("filetype plugin on")
vim.cmd("filetype indent on")
vim.cmd("highlight WinSeparator guibg=None")
vim.cmd("packadd cfilter")

vim.api.nvim_set_hl(0, "VirtualTextWarning", {link= "Grey"})
vim.api.nvim_set_hl(0, "VirtualTextError", {link= "DiffDelete"})
vim.api.nvim_set_hl(0, "VirtualTextInfo", {link= "DiffChange"})
vim.api.nvim_set_hl(0, "VirtualTextHint", {link= "DiffAdd"})

local map = vim.keymap.set
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
map("n", "<leader>'", ":silent args `fd `<left>")
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


function qf(inputs)
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
      vim.fn.setqflist(
        {}, "a", {
          id=id, title=title,
          lines=lines
        }
      )
      if (not in_qf()) or (is_at_last_line() and in_qf()) then
        vim.cmd ":cbottom"
      end
    end)
  end
end

local last_job_state = nil
local last_job_thunk = nil
function qfjob(cmd, stdin)
  local title = table.concat(cmd, " ")
  vim.fn.setqflist({}, " ", {title=title})
  local append_lines = qf(vim.fn.getqflist({id=0,title=1}))
  last_job_state = vim.system(
    cmd, {
      stdin=stdin,
      stdout=function(err,data)
        if data then
          append_lines(data:gmatch("[^\n]+"))
        end
      end,
      stderr=function(err,data)
        if data then
          append_lines(data:gmatch("[^\n]+"))
        end
      end,
    },
    function(job)
      vim.schedule(function()
        local winnr = vim.fn.winnr()
        if not (job.code == 0) then
          cope()
          if not (winnr == vim.fn.winnr()) then
            vim.notify([["]] .. title .. [[" failed!]])
            vim.cmd "wincmd p | cbot"
          end
        else
          vim.notify([["]] .. title .. [[" succeeded!]])
        end
      end)
    end)
end

vim.api.nvim_create_user_command(
  "Sh",
  function(cmd)
    local thunk = function() qfjob({ "zshcmd", cmd.args }, nil) end
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

-- (fn browse_git_remote
--   [data]
--   (P data)
--   (local
--     {: commit
--      : git_dir
--      : line1
--      : line2
--      : path
--      : remote
--      : remote_name
--      : repo
--      : type } data)
--
--   (local
--     oilpath
--     (case (vim.fn.bufname "%")
--       (where oilbuf (vim.startswith oilbuf "oil://"))
--       (do
--         (local d (.. "oil://" (vim.fs.dirname git_dir) "/"))
--         (oilbuf:sub (+ 1 (d:len)) (oilbuf:len)))
--       _
--       ""))
--
--   (local [home repo]
--     (case remote
--       (where s (vim.startswith s "git@"))
--       (do
--         (or
--           (case [(s:match "(git@)([^:]+):(.*)(%.git)")]
--               ["git@" home repo ".git"]
--               [home repo])
--           (case [(s:match "(git@)([^:]+):.*/(.*)/(.*)/(.*)")]
--               ["git@" home org project repo]
--               [(home:gsub "ssh%." "") [(.. org "/" project) repo]])))))
--
--   (case [home repo]
--     (where ["bitbucket.org" repo])
--     (do
--       (case [path type]
--         ["" "tree"]
--         (.. "https://" home "/" repo "/src/" commit "/" (or oilpath path ""))
--         [path "blob"]
--         (.. "https://" home "/" repo "/src/" commit "/" path)
--         [path "commit"]
--         (.. "https://" home "/" repo "/commits/" commit)
--         [path "ref"]
--         (.. "https://" home "/" repo "/commits/" commit)))
--     (where ["dev.azure.com" [org repo]])
--     (do
--       (case [path type]
--         ["" "tree"]
--         (.. "https://" home "/" org "/_git/" repo "?version=GB" commit "&path=/" (or oilpath path ""))
--         [path "blob"]
--         (.. "https://" home "/" org "/_git/" repo "?version=GB" commit "&path=/" path)
--         [path "commit"]
--         (.. "https://" home "/" org "/_git/" repo "/commit/" commit)
--         [path "ref"]
--         (.. "https://" home "/" org "/_git/" repo "/commit/" commit)))
--     (where ["gitlab.com" repo])
--     (do
--       (case [path type]
--         ["" "tree"]
--         (.. "https://" home "/" repo "/-/tree/" commit "/" (or oilpath ""))
--         [path "commit"]
--         (.. "https://" home "/" repo "/-/commit/" commit)
--         [path "ref"]
--         (.. "https://" home "/" repo "/-/commit/" commit)
--         [path "blob"]
--         (.. "https://" home "/" repo "/-/blob/" commit "/" path)))
--     (where ["github.com" repo])
--     (do
--       (case [path type]
--         ["" "tree"]
--         (.. "https://" home "/" repo "/tree/" commit "/" (or oilpath ""))
--         [path "commit"]
--         (.. "https://" home "/" repo "/commit/" commit)
--         [path "ref"]
--         (.. "https://" home "/" repo "/commit/" commit)
--         [path "blob"]
--         (.. "https://" home "/" repo "/blob/" commit "/" path)))))
--
-- (vim.api.nvim_create_user_command
--   :Browse
--   (fn [{: args}] (vim.system ["xdg-open" args] {} (fn [])))
--   {:nargs 1})
--
-- (set vim.g.fugitive_browse_handlers
--      [browse_git_remote])

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
   vim.system({"xclip"}, {text= true, stdin=lines}, function(exit) end)
   vim.system({"xclip", "-selection", "clipboard"}, {text= true, stdin=lines}, function(exit) end)
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
