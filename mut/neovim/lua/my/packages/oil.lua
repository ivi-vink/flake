local oil=require("oil")
local fzf=require("fzf-lua")
local map = vim.keymap.set
local unmap = vim.keymap.del

oil.setup({
  default_file_explorer =  true,
  skip_confirm_for_simple_edits =  true,

  columns =  {"size","permissions"},
  view_options = {
    show_hidden =  false,
    is_hidden_file = function(name, bufnr)
      return vim.startswith(name, ".")
    end,
    is_always_hidden = function(name, bufnr) return false end,
    sort =  { {"type" ,"asc"}, {"name","asc"} }
  },


  keymaps = {
    ["g?"] = "actions.show_help",
    ["<CR>"] =  "actions.select",
    ["<C-s>"] = function()
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
    end,
    [ "<C-h>" ] =  "actions.select_split",
    [ "<C-t>" ] =  "actions.select_tab",
    [ "<C-p>" ] =  fzf.files,
    [ "<C-c>" ] =  "actions.close",
    [ "<C-l>" ] =  "actions.refresh",
    [ "." ] =  "actions.open_cmdline",
    [ "gx" ] =  {
      callback = function()
      local file, dir = oil.get_cursor_entry(), oil.get_current_dir()
      if dir and file then
        vim.cmd("argadd " .. dir .. file.name)
        vim.cmd "args"
      end
    end
  },
    [ "gX" ] =  {
      callback = function()
      local file, dir = oil.get_cursor_entry(), oil.get_current_dir()
      if dir and file then
        vim.cmd("argdel " .. dir .. file.name)
        vim.cmd "args"
      end
    end
  },
    [ "gc" ] =  {
      callback = function()
      vim.cmd("argdel *")
      vim.cmd("args")
    end
  },
    [ "-" ] =  "actions.parent",
    [ "_" ] =  "actions.open_cwd",
    [ "cd" ] =  "actions.cd",
    [ "~" ] =  "actions.tcd",
    [ "gs" ] =  "actions.change_sort",
    [ "g." ] =  "actions.toggle_hidden"
  }
})
