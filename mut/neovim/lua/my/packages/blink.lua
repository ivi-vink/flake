local blink = require('blink.cmp')
blink.setup {
-- When specifying 'preset' in the keymap table, the custom key mappings are merged with the preset,
  -- and any conflicting keys will overwrite the preset mappings.
  -- The "fallback" command will run the next non blink keymap.
  --
  -- Example:
  --
  -- keymap = {
  --   preset = 'default',
  --   ['<Up>'] = { 'select_prev', 'fallback' },
  --   ['<Down>'] = { 'select_next', 'fallback' },
  --
  --   -- disable a keymap from the preset
  --   ['<C-e>'] = {},
  --
  --   -- show with a list of providers
  --   ['<C-space>'] = { function(cmp) cmp.show({ providers = { 'snippets' } }) end },
  --
  --   -- note that your function will often be run in a "fast event" where most vim.api functions will throw an error
  --   -- you may want to wrap your function in `vim.schedule` or use `vim.schedule_wrap`
  --   ['<C-space>'] = { function(cmp) vim.schedule(function() your_behavior end) },
  --
  --   -- optionally, define different keymaps for cmdline
  --   cmdline = {
  --     preset = 'super-tab'
  --   }
  -- }
  --
  -- When defining your own keymaps without a preset, no keybinds will be assigned automatically.
  --
  -- Available commands:
  --   show, hide, cancel, accept, select_and_accept, select_prev, select_next, show_documentation, hide_documentation,
  --   scroll_documentation_up, scroll_documentation_down, snippet_forward, snippet_backward, fallback
  --
  -- "default" keymap
  --   ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
  --   ['<C-e>'] = { 'hide' },
  --   ['<C-y>'] = { 'select_and_accept' },
  --
  --   ['<C-p>'] = { 'select_prev', 'fallback' },
  --   ['<C-n>'] = { 'select_next', 'fallback' },
  --
  --   ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
  --   ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
  --
  --   ['<Tab>'] = { 'snippet_forward', 'fallback' },
  --   ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
  --
  -- "super-tab" keymap
  --   you may want to set `completion.trigger.show_in_snippet = false`
  --   or use `completion.list.selection = "manual" | "auto_insert"`
  --
  --   ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
  --   ['<C-e>'] = { 'hide', 'fallback' },
  --
  --   ['<Tab>'] = {
  --     function(cmp)
  --       if cmp.snippet_active() then return cmp.accept()
  --       else return cmp.select_and_accept() end
  --     end,
  --     'snippet_forward',
  --     'fallback'
  --   },
  --   ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
  --
  --   ['<Up>'] = { 'select_prev', 'fallback' },
  --   ['<Down>'] = { 'select_next', 'fallback' },
  --   ['<C-p>'] = { 'select_prev', 'fallback' },
  --   ['<C-n>'] = { 'select_next', 'fallback' },
  --
  --   ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
  --   ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
  --
  -- "enter" keymap
  --   you may want to set `completion.list.selection = "manual" | "auto_insert"`
  --
  --   ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
  --   ['<C-e>'] = { 'hide', 'fallback' },
  --   ['<CR>'] = { 'accept', 'fallback' },
  --
  --   ['<Tab>'] = { 'snippet_forward', 'fallback' },
  --   ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
  --
  --   ['<Up>'] = { 'select_prev', 'fallback' },
  --   ['<Down>'] = { 'select_next', 'fallback' },
  --   ['<C-p>'] = { 'select_prev', 'fallback' },
  --   ['<C-n>'] = { 'select_next', 'fallback' },
  --
  --   ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
  --   ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
  keymap = { preset = 'default' },

  -- Enables keymaps, completions and signature help when true
  enabled = function() return vim.bo.buftype ~= "prompt" and vim.b.completion ~= false end,
  -- Example for blocking multiple filetypes
  -- enabled = function()
  --  return not vim.tbl_contains({ "lua", "markdown" }, vim.bo.filetype)
  --    and vim.bo.buftype ~= "prompt"
  --    and vim.b.completion ~= false
  -- end,

  snippets = {
    -- Function to use when expanding LSP provided snippets
    expand = function(snippet) vim.snippet.expand(snippet) end,
    -- Function to use when checking if a snippet is active
    active = function(filter) return vim.snippet.active(filter) end,
    -- Function to use when jumping between tab stops in a snippet, where direction can be negative or positive
    jump = function(direction) vim.snippet.jump(direction) end,
  },

  signature = {
    enabled = true,
    trigger = {
      blocked_trigger_characters = {},
      blocked_retrigger_characters = {},
      -- When true, will show the signature help window when the cursor comes after a trigger character when entering insert mode
      show_on_insert_on_trigger_character = true,
    },
    window = {
      min_width = 1,
      max_width = 100,
      max_height = 10,
      border = 'padded',
      winblend = 0,
      winhighlight = 'Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder',
      scrollbar = false, -- Note that the gutter will be disabled when border ~= 'none'
      -- Which directions to show the window,
      -- falling back to the next direction when there's not enough space,
      -- or another window is in the way
      direction_priority = { 'n', 's' },
      -- Disable if you run into performance issues
      treesitter_highlighting = true,
    },
  },

  sources = {
    -- Static list of providers to enable, or a function to dynamically enable/disable providers based on the context
    default = { 'lsp', 'path', 'snippets', 'buffer' },
    -- Example dynamically picking providers based on the filetype and treesitter node:
    -- providers = function(ctx)
    --   local node = vim.treesitter.get_node()
    --   if vim.bo.filetype == 'lua' then
    --     return { 'lsp', 'path' }
    --   elseif node and vim.tbl_contains({ 'comment', 'line_comment', 'block_comment' }, node:type()) then
    --     return { 'buffer' }
    --   else
    --     return { 'lsp', 'path', 'snippets', 'buffer' }
    --   end
    -- end

    -- You may also define providers per filetype
    per_filetype = {
      -- lua = { 'lsp', 'path' },
    },

    -- By default, we choose providers for the cmdline based on the current cmdtype
    -- You may disable cmdline completions by replacing this with an empty table
    cmdline = function()
      local type = vim.fn.getcmdtype()
      -- Search forward and backward
      if type == '/' or type == '?' then return { 'buffer' } end
      -- Commands
      if type == ':' then return { 'cmdline' } end
      return {}
    end,

    -- Function to use when transforming the items before they're returned for all providers
    -- The default will lower the score for snippets to sort them lower in the list
    transform_items = function(_, items)
      for _, item in ipairs(items) do
        if item.kind == require('blink.cmp.types').CompletionItemKind.Snippet then
          item.score_offset = item.score_offset - 3
        end
      end
      return items
    end,
    -- Minimum number of characters in the keyword to trigger all providers
    -- May also be `function(ctx: blink.cmp.Context): number`
    min_keyword_length = 0,
    -- Example for setting a minimum keyword length for markdown files
    -- min_keyword_length = function()
    --   return vim.bo.filetype == 'markdown' and 2 or 0
    -- end,

    -- Please see https://github.com/Saghen/blink.compat for using `nvim-cmp` sources
    providers = {
      lsp = {
        name = 'LSP',
        module = 'blink.cmp.sources.lsp',
        -- Filter out text items from the LSP provider, since we have the buffer provider for that
        transform_items = function(_, items)
          return vim.tbl_filter(
            function(item) return item.kind ~= require('blink.cmp.types').CompletionItemKind.Text end,
            items
          )
        end,

        --- *All* providers have the following options available
        --- NOTE: All of these options may be functions to get dynamic behavior
        --- See the type definitions for more information.
        enabled = true, -- Whether or not to enable the provider
        async = false, -- Whether we should wait for the provider to return before showing the completions
        timeout_ms = 2000, -- How long to wait for the provider to return before showing completions and treating it as asynchronous
        transform_items = nil, -- Function to transform the items before they're returned
        should_show_items = true, -- Whether or not to show the items
        max_items = nil, -- Maximum number of items to display in the menu
        min_keyword_length = 0, -- Minimum number of characters in the keyword to trigger the provider
        -- If this provider returns 0 items, it will fallback to these providers.
        -- If multiple providers falback to the same provider, all of the providers must return 0 items for it to fallback
        fallbacks = { 'buffer' },
        score_offset = 0, -- Boost/penalize the score of the items
        override = nil, -- Override the source's functions
      },
      path = {
        name = 'Path',
        module = 'blink.cmp.sources.path',
        score_offset = 3,
        fallbacks = { 'buffer' },
        opts = {
          trailing_slash = false,
          label_trailing_slash = true,
          get_cwd = function(context) return vim.fn.expand(('#%d:p:h'):format(context.bufnr)) end,
          show_hidden_files_by_default = false,
        }
      },
      snippets = {
        name = 'Snippets',
        module = 'blink.cmp.sources.snippets',
        opts = {
          friendly_snippets = true,
          search_paths = { vim.fn.stdpath('config') .. '/snippets' },
          global_snippets = { 'all' },
          extended_filetypes = {},
          ignored_filetypes = {},
          get_filetype = function(context)
            return vim.bo.filetype
          end
        }

        --- Example usage for disabling the snippet provider after pressing trigger characters (i.e. ".")
        -- enabled = function(ctx)
        --   return ctx ~= nil and ctx.trigger.kind == vim.lsp.protocol.CompletionTriggerKind.TriggerCharacter
        -- end,
      },
      luasnip = {
        name = 'Luasnip',
        module = 'blink.cmp.sources.luasnip',
        opts = {
          -- Whether to use show_condition for filtering snippets
          use_show_condition = true,
          -- Whether to show autosnippets in the completion list
          show_autosnippets = true,
        }
      },
      buffer = {
        name = 'Buffer',
        module = 'blink.cmp.sources.buffer',
        opts = {
          -- default to all visible buffers
          get_bufnrs = function()
            return vim
              .iter(vim.api.nvim_list_wins())
              :map(function(win) return vim.api.nvim_win_get_buf(win) end)
              :filter(function(buf) return vim.bo[buf].buftype ~= 'nofile' end)
              :totable()
          end,
        }
      },
    },
  },

  appearance = {
    highlight_ns = vim.api.nvim_create_namespace('blink_cmp'),
    -- Sets the fallback highlight groups to nvim-cmp's highlight groups
    -- Useful for when your theme doesn't support blink.cmp
    -- Will be removed in a future release
    use_nvim_cmp_as_default = false,
    -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    -- Adjusts spacing to ensure icons are aligned
    nerd_font_variant = 'mono',
    kind_icons = {
      Text = '󰉿',
      Method = '󰊕',
      Function = '󰊕',
      Constructor = '󰒓',

      Field = '󰜢',
      Variable = '󰆦',
      Property = '󰖷',

      Class = '󱡠',
      Interface = '󱡠',
      Struct = '󱡠',
      Module = '󰅩',

      Unit = '󰪚',
      Value = '󰦨',
      Enum = '󰦨',
      EnumMember = '󰦨',

      Keyword = '󰻾',
      Constant = '󰏿',

      Snippet = '󱄽',
      Color = '󰏘',
      File = '󰈔',
      Reference = '󰬲',
      Folder = '󰉋',
      Event = '󱐋',
      Operator = '󰪚',
      TypeParameter = '󰬛',
    },
  },
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
