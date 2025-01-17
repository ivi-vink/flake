local blink = require('blink.cmp')
blink.setup {
    -- 'default' for mappings similar to built-in completion
    -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
    -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
    -- See the full "keymap" documentation for information on defining your own keymap.
    keymap = { preset = 'default' },

    appearance = {
      -- Sets the fallback highlight groups to nvim-cmp's highlight groups
      -- Useful for when your theme doesn't support blink.cmp
      -- Will be removed in a future release
      use_nvim_cmp_as_default = true,
      -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono'
    },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    snippets = { preset = 'luasnip' },
}

local map = vim.keymap.set
local unmap = vim.keymap.del
local event = vim.api.nvim_create_autocmd
map("n", "<leader>xf", function()
  event({"CmdwinEnter"}, {
    once = true,
    callback = function()
      map("i","<c-j>", function()
        blink.hide()
        vim.schedule(function()
          vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes("<cr>", true, false, true),
            "c", false)
        end)
      end,{buffer=true})
      map("i","<bs>","<c-o>vT/d",{buffer=true})
    end
  })
  event({"CmdwinLeave"}, {
    once = true,
    callback = function()
      unmap("i","<c-j>",{buffer=true})
      unmap("i","<bs>",{buffer=true})
    end
  })
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(":edit <c-r>=expand('%:p:h')<cr><c-f>A/", true, false, true),
    "c", false)
end)
