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
      k9s
      kubernetes-helm
      azure-cli
      kubectl

      htop
      fortune
      vim
      dmenu
      stow
      (nerdfonts.override {fonts = ["FiraCode"];})
      subversion
      ripgrep
      inotify-tools

      firefox-wayland

      swaylock
      swayidle
      wl-clipboard
      mako
      wofi
      waybar

      (import ./home/st.nix {inherit pkgs;})
    ]
    ++ (import ./shell-scripts.nix {inherit pkgs config;});

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      s = "sudo nixos-rebuild switch --flake ${config.home.homeDirectory}/flake#";
      h = "home-manager switch --flake ${config.home.homeDirectory}/flake#${config.home.username}";
      V = "xrandr --output HDMI1 --auto --output eDP1 --off";
      v = "xrandr --output eDP1 --auto --output HDMI1 --off";
      vV = "xrandr --output eDP1 --auto --output HDMI1 --off";
      newflake = "nix flake new -t ~/flake ";
    };
  };

  programs.git = {
    enable = true;
    userName = "Mike Vink";
    userEmail = "mike1994vink@gmail.com";
    ignores = [
      "/.direnv/"
      "/.envrc"
    ];
  };

  programs.gpg = {
      enable = true;
  };
  services.gpg-agent = {
      enable = true;
  };
  programs.password-store = {
      enable = true;
  };

  xsession = {
    enable = true;
    windowManager.spectrwm = {
      enable = true;
      programs = {
        term = "st";
        search = "dmenu -ip -p 'Window name/id:'";
        browser = "firefox";
        lock = "slock";
      };
      bindings = {
        lock = "Mod+s";
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
        bar_action = "spectrwmbar";
        bar_action_expand = 1;
        bar_font_color = "grey, white,  rgb:00/00/ff,  rgb:ee/82/ee,  rgb:4b/00/82,  rgb:00/80/00,  rgb:ff/ff/00,  rgb:ff/a5/00, rgb:eb/40/34";
      };
    };
  };

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
