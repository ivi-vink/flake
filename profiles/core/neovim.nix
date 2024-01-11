{
  pkgs,
  ...
}: {
  hm = {
    # https://github.com/nix-community/home-manager/issues/4692
    # xdg = {
    #   configFile = with config.lib.meta; {
    #     "nvim".source = mkMutableSymlink /mut/neovim;
    #   };
    # };

    editorconfig = {
      enable = true;
      settings = {
        "*" = {
          trim_trailing_whitespace = true;
          insert_final_newline = true;
        };
        "*.yaml" = {
          indent_style = "space";
          indent_size = 2;
        };
        "*.nix" = {
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
        bashInteractive
        pyright
        gopls
        fennel
        fnlfmt
        alejandra
        statix
        fzf
        bat
        nil
        shellcheck
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

        # external
        oil-nvim
        vim-fugitive
        vim-oscyank
        venn-nvim
        gv-vim
        zoxide-vim

        # Coding
        fzf-lua
        nvim-lspconfig
        null-ls-nvim
        lsp_signature-nvim
        nvim-dap
        nvim-dap-ui
        luasnip
        vim-test
        nvim-lint

        # cmp
        nvim-cmp
        cmp-cmdline
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        cmp_luasnip

        # trying out lisp
        # conjure
        vim-racket
        nvim-parinfer
        hotpot-nvim
      ];
    };
  };
}
