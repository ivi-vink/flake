{
  flake,
  config,
  pkgs,
  home-manager,
  ...
}: {
  home.activation = {
    # links neovim repo to xdg config home
    neovim-symlink = home-manager.lib.hm.dag.entryAfter ["writeBoundary"] ''
      NEOVIM_CONFIG="${config.home.homeDirectory}/neovim"
      XDG_CONFIG_HOME_NVIM="${config.xdg.configHome}/nvim"
      if [ -L $XDG_CONFIG_HOME_NVIM ] && [ -e $XDG_CONFIG_HOME_NVIM ]; then
          $DRY_RUN_CMD echo "neovim linked"
      else
          $DRY_RUN_CMD ln -s $NEOVIM_CONFIG $XDG_CONFIG_HOME_NVIM
      fi
    '';
    # fixes hotpot cannot be found error after updates
    clearHotpotCache = home-manager.lib.hm.dag.entryAfter ["writeBoundary"] ''
      HOTPOT_CACHE="${config.xdg.cacheHome}/nvim/hotpot"
      if [[ -d "$HOTPOT_CACHE" ]]; then
        $DRY_RUN_CMD rm -rf "$VERBOSE_ARG" "$HOTPOT_CACHE"
      fi
    '';
  };

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      bashInteractive
      fennel
      sumneko-lua-language-server
      pyright
      gopls
      yaml-language-server
      alejandra
      statix
      fnlfmt
    ];
    plugins = with pkgs.vimPlugins; [
      # highlighting
      nvim-treesitter.withAllGrammars
      nvim-ts-rainbow
      playground
      gruvbox-material
      vim-just
      lsp_lines-nvim

      # external
      vim-dirvish
      vim-fugitive
      vim-oscyank

      # Coding
      codeium-vim
      nvim-lspconfig
      nvim-dap
      nvim-dap-ui
      luasnip
      trouble-nvim
      null-ls-nvim
      plenary-nvim
      nlua-nvim
      lsp_signature-nvim
      vim-test
      vim-rest-console

      # cmp
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp_luasnip

      # trying out lisp
      conjure
      vim-racket
      nvim-parinfer
      hotpot-nvim
      cmp-conjure
    ];
  };
}