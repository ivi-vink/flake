local lsp = require("my.lsp")
local oil = require("oil")
local lint = require("lint")
local event = vim.api.nvim_create_autocmd
local command = vim.api.nvim_create_user_command

vim.api.nvim_create_augroup("my", {clear= true})
vim.api.nvim_create_augroup("conf#events", {clear= true})

event(
  "User",
  {group= "conf#events",
   pattern= { "ZoxideDirChanged" },
   callback= function()
     vim.schedule(function()
       oil.open(vim.fn.getcwd)
     end)
   end})

event(
  "BufReadPost",
  {group= "conf#events",
   pattern= { "*" },
   callback=function()
     local pattern = "'\\s\\+$'"
     vim.cmd("syn match TrailingWhitespace " .. pattern)
     vim.cmd("hi link TrailingWhitespace IncSearch")
   end})

event(
  "BufWritePost",
  {group= "conf#events",
   pattern={ "*" },
   callback=function()
     lint.try_lint()
     vim.schedule(function() vim.diagnostic.setloclist({open= false}) end)
   end})

local session_file = vim.fn.expand("~/.vimsession.vim")
event(
  "VimLeave",
  {group= "conf#events",
   pattern= { "*" },
   callback=function()
     vim.cmd("mksession! " .. session_file)
   end})

event(
  "LspAttach",
  {group = "conf#events",
   pattern = { "*" },
   callback = function(ev)
     lsp.attach({
       client = vim.lsp.get_client_by_id(ev.data.client_id),
       buf = ev.buf,
     })
   end})

event(
  "LspAttach",
  {group = "conf#events",
   pattern = { "*" },
   callback = function(ev)
     lsp.attach({
       client = vim.lsp.get_client_by_id(ev.data.client_id),
       buf = ev.buf,
     })
   end})

event(
  "FileType", {
    group="conf#events",
    pattern={ "go", "gomod", "gowork", "gotmpl" },
    callback=function(ev)
      vim.lsp.start({
        name="gopls",
        cmd={ "gopls" },
        root_dir=vim.fs.root(ev.buf, {"go.work", "go.mod", ".git"})
      })
    end,
  })
