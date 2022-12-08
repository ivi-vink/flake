{
  flake,
  config,
  pkgs,
  home-manager,
  ...
}: {
  home.username = "mike";
  home.homeDirectory = "/home/mike";
  home.stateVersion = "22.05";
  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.packages = with pkgs;
    [
      docker
      kubectl
      k9s
      kubernetes-helm
      azure-cli

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
    ]
    ++ (import ./shell-scripts.nix {inherit pkgs;});

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      newflake = "nix flake new -t github:nix-community/nix-direnv ";
    };
  };

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

  # fixes hotpot cannot be found error after updates
  home.activation = {
    neovim-symlink = home-manager.lib.hm.dag.entryAfter ["writeBoundary"] ''
      NEOVIM_CONFIG="${config.home.homeDirectory}/neovim"
      XDG_CONFIG_HOME_NVIM="${config.xdg.configHome}/nvim"
      $DRY_RUN_CMD ln -sf $NEOVIM_CONFIG $XDG_CONFIG_HOME_NVIM
    '';
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
      (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))
      nvim-ts-rainbow
      playground
      gruvbox-material
      vim-just

      # external
      vim-dirvish
      vim-fugitive
      vim-oscyank

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
      vim-rest-console

      # testing
      neotest
      neotest-python

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
