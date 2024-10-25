local cmp = require("cmp")
local cmp_types = require("cmp.types")
local luasnip = require("luasnip")

vim.keymap.set("n", "<leader>xf",
  function()
    local fname = vim.fn.fnamemodify(vim.fn.bufname(vim.api.nvim_get_current_buf()), ":p:h")
    vim.api.nvim_feedkeys(":e " .. fname, "c", false)
    vim.defer_fn(function()
      vim.api.nvim_feedkeys("/", "c", false)
    end, 10)
  end)

function snip(args)
  luasnip.lsp_expand(args.body)
end

function has_words_before()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  local word = unpack(vim.api.nvim_buf_get_lines(0, line-1, line, true))
  local before = word:sub(col, col)
  local is_whitespace = before:match("%s")

  local is_not_first_col = (not (col == 0))
  local is_not_whitespace = (is_whitespace == nil)
  local result =  is_not_first_col and is_not_whitespace
  return result
end

function in_edit_mode(line)
  return line:match("^.* %.?.*$") or line:match("^ed?i?t? .*$")
end

function endswith(line, char)
  return line:match(".*" .. char .. "$")
end

function replace_tail(line)
  local result, n = line:gsub("(.*/)[^/]*/$","%1")
  if n then
    return result
  else
    return line
  end
end

cmp.setup({
  experimental={ghost_text= true},
  snippet={expand="snip"},
  preselect=cmp.PreselectMode.None,
  sources=cmp.config.sources({
    {name= "nvim_lsp"},
    {name= "path"},
    {name= "luasnip"}
  }),
  mapping={
    ["<Tab>"]=cmp.mapping(
      function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, {"i", "s"}),
    ["<S-Tab>"]=cmp.mapping(
      function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump (1)
        else
          fallback()
        end
      end, { "i", "s" }),
    ["<C-b>"]=cmp.mapping.scroll_docs(-4),
    [ "<C-f>" ]= cmp.mapping.scroll_docs(4),
    [ "<C-j>" ]= cmp.mapping.complete(),
    [ "<CR>" ]= cmp.mapping.confirm({
      behavior=cmp.ConfirmBehavior.Insert,
      select=true}),
    },
})

-- This tries to emulate somewhat ido mode to find files
-- todo sorting based on least recently used
cmp.setup.cmdline(":",
{enabled=function()
  local val = in_edit_mode(vim.fn.getcmdline())
  if not val then cmp.close() end
  return val
end,
sources=cmp.config.sources({ {name="path"} }),
completion={completeopt="menu,menuone,noinsert"},
mapping={
  ["<C-n>"]=cmp.mapping(
    function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        cmp.complete()
      end
    end, { "i", "c" }),
  ["<C-p>"]=cmp.mapping(
    function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        cmp.complete()
      end
    end, { "i", "c" }),
  ["<BS>"]=cmp.mapping(
    function(fallback)
      local line = vim.fn.getcmdline()
      if not endswith(line, "/") then
        fallback()
      else
        vim.fn.setcmdline(replace_tail(line))
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<C-g><BS>", true, false, true), false)
        vim.defer_fn(cmp.complete, 10)
      end
    end, { "i", "c" }),
  ["<CR>"]=cmp.mapping(
    function(fallback)
      local entry = cmp.get_selected_entry()
      local line = vim.fn.getcmdline()
      if entry and (not in_edit_mode(line)) then
        vim.schedule(fallback)
      else
        cmp.confirm {select=true, behavior=cmp.ConfirmBehavior.Replace}
        if entry and entry.completion_item.label:match("%.*/$") then
          vim.defer_fn(cmp.complete, 10)
        else
          vim.schedule(fallback)
        end
      end
    end, { "i", "c"})
  }
})
