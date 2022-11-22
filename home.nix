{
  flake,
  config,
  pkgs,
  home-manager,
  ...
}: {
  # Found this here: nix-community.github.io  configuration example

  home.username = "mike";
  home.homeDirectory = "/home/mike";
  home.stateVersion = "22.05";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    docker
    kubectl
    k9s

    htop
    fortune
    vim
    stow
    (nerdfonts.override {fonts = ["FiraCode"];})
    ripgrep
    inotify-tools

    firefox-wayland

    swaylock
    swayidle
    wl-clipboard
    mako
    wofi
    waybar
  ];

  programs.git = {
    enable = true;
    userName = "Mike Vink";
    userEmail = "mike1994vink@gmail.com";
  };

  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "alacritty";
      font = {
        normal = {
          family = "FiraCode Nerd Font";
          style = "Regular";
        };
      };
    };
  };

  xsession = {
    enable = true;
    windowManager.spectrwm = {
      enable = true;
      programs = {
        term = "alacritty";
        search = "dmenu -ip -p 'Window name/id:'";
        browser = "firefox";
      };
      bindings = {
        browser = "Mod+w";
        term = "Mod+Return";
        restart = "Mod+Shift+r";
        quit = "Mod+Shift+q";
      };
      settings = {
        modkey = "Mod4";
        workspace_limit = 5;
        focus_mode = "manual";
        focus_close = "next";
      };
    };
  };

  home.activation = {
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
      fennel
      sumneko-lua-language-server
      pyright
      gopls
      yaml-language-server
      alejandra
      statix
      fnlfmt
    ];
    extraConfig = "
lua <<LUA
Flake = {
    lua_language_server = [[${pkgs.sumneko-lua-language-server}]],
    bash = [[${pkgs.bashInteractive}/bin/bash]]
}
vim.opt.runtimepath:append({ [[~/dotnix/neovim]], [[~/dotnix/neovim/lua]],  [[~/dotnix/neovim/fnl]]})
package.path = [[/home/mike/dotnix/?/init.lua;]] .. [[/home/mike/dotnix/?/?;]] .. [[/home/mike/.cache/nvim/hotpot/hotpot.nvim/lua/?/init.lua;]] .. package.path
require'neovim'
LUA
      ";
    plugins = with pkgs.vimPlugins; [
      # highlighting
      (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))
      nvim-ts-rainbow
      playground
      gruvbox-material

      # external
      vim-dirvish
      vim-fugitive
      vim-oscyank
      firvish-nvim

      # moving around
      marks-nvim

      # Coding
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
