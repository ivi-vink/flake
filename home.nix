{ flake, config, pkgs, ... }:

{
    # Found this here: nix-community.github.io  configuration example

    home.username = "mike";
    home.homeDirectory = "/home/mike";
    home.stateVersion = "22.05";
    programs.home-manager.enable = true;
    
    home.packages = with pkgs; [
        htop
        fortune
        vim
        docker
        stow
        (nerdfonts.override { fonts = [ "FiraCode" ]; })

        firefox

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

    wayland.windowManager.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
        config = rec {
            terminal = "alacritty";
	    menu = "wofi --show run";
            modifier = "Mod4";
            bars = [{
              fonts.size = 15.0;
              position = "bottom";
            }];            
            startup = [
                {command = "firefox";}
            ];
        };
    };
    
    # netrc-file = ~/.netrc;

    programs.neovim = {
      enable = true;
      package = pkgs.neovim-unwrapped;
      viAlias = true;
      vimAlias = true;
      extraConfig = "
lua <<LUA
vim.opt.runtimepath:append({ [[${flake}/neovim]], [[${flake}/neovim/lua]] })
vim.cmd [[luafile ${flake}/neovim/init.lua]]
LUA
      ";
      plugins = with pkgs.vimPlugins;
        let
          fetchPluginFromGit = name: rev: pkgs.vimUtils.buildVimPluginFrom2Nix {
            name = name;
            src = builtins.fetchGit {
              url = "https://github.com/${name}";
              submodules = true;
              inherit rev;
            };
          };
        in [
          vim-nix
          vim-dirvish
          nvim-dap
          nvim-dap-ui
          vim-fugitive
          gruvbox-material
          luasnip
          nvim-lspconfig
          trouble-nvim
          nlua-nvim
          null-ls-nvim
          plenary-nvim
          

          (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))
          playground

          (fetchPluginFromGit  "klen/nvim-test" "32f162c27045fc712664b9ddbd33d3c550cb2bfc")
          (fetchPluginFromGit  "mvinkio/tnychain" "cef72f688e67f40616db8ecf9d7c63e505c2dd23")
          (fetchPluginFromGit  "Furkanzmc/firvish.nvim" "127f9146175d6bbaff6a8b761081cfd2279f8351")
          (fetchPluginFromGit  "ray-x/lsp_signature.nvim" "137bfaa7c112cb058f8e999a8fb49363fae3a697")
        ];
    };
}
