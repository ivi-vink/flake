{
  inputs,
  config,
  pkgs,
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
        "*.yaml" = {
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
        vim-dirvish
        vim-fugitive
        vim-oscyank
        venn-nvim
        gv-vim

        # Coding
        plenary-nvim
        telescope-nvim
        nvim-lspconfig
        null-ls-nvim
        lsp_signature-nvim
        nvim-dap
        nvim-dap-ui
        luasnip
        vim-test
        vim-rest-console

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
