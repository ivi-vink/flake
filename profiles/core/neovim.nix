{
  pkgs,
  config,
  ...
}: {
  hm = {
    xdg = {
      configFile = with config.lib.meta; {
        "nvim".source = mkMutableSymlink /mut/neovim;
      };
    };

    editorconfig = {
      enable = true;
      settings = {
        "*" = {
          trim_trailing_whitespace = true;
          insert_final_newline = true;
        };
        "*.{yaml,nix,sh}" = {
          indent_style = "space";
          indent_size = 2;
        };
      };
    };

    programs.neovim = {
      enable = true;
      package = pkgs.neovim-unwrapped;
      viAlias = true;
      vimAlias = true;
      extraPackages = with pkgs; [
        # bashInteractive
        # pyright
        # gopls
        # fennel
        # fnlfmt
        # alejandra
        # statix
        # fzf
        # nil
        # shellcheck
        # vale
      ];
      plugins = with pkgs.vimPlugins; [
        # highlighting
        nvim-treesitter.withAllGrammars
        playground
        gruvbox-material
        kanagawa-nvim
        lsp_lines-nvim
        gitsigns-nvim
        vim-helm
        lualine-nvim

        # external
        oil-nvim
        vim-fugitive
        venn-nvim
        gv-vim
        zoxide-vim
        obsidian-nvim
        go-nvim

        # Coding
        fzf-lua
        nvim-lspconfig
        null-ls-nvim
        lsp_signature-nvim
        nvim-dap
        nvim-dap-ui
        nvim-nio
        nvim-dap-python
        luasnip
        vim-test
        nvim-lint
        vim-surround
        conform-nvim
        trouble-nvim
        vim-easy-align
        nvim-comment
        nvim-cinnamon

        # cmp
        nvim-cmp
        cmp-cmdline
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        cmp_luasnip

        # trying out lisp
        conjure
        vim-racket
        nvim-parinfer

        # ai :(
        # render-markdown-nvim
        # avante-nvim
        # nui-nvim
      ];
    };
  };
}
