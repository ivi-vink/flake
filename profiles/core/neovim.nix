{
  pkgs,
  config,
  ...
}: {
  hm = {
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
        gruvbox-material
        kanagawa-nvim
        lsp_lines-nvim
        gitsigns-nvim
        vim-helm

        # external
        oil-nvim
        vim-fugitive
        gv-vim
        zoxide-vim
        obsidian-nvim
        go-nvim

        # Debug adapter
        nvim-dap
        nvim-dap-ui
        nvim-nio
        nvim-dap-python

        # editing
        fzf-lua
        nvim-lspconfig
        lsp_signature-nvim
        luasnip
        nvim-lint
        vim-surround
        conform-nvim
        trouble-nvim
        vim-easy-align
        nvim-comment
      ];
    };
  };
}
