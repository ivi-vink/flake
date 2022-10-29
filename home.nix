{ config, pkgs, ... }:

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
      package = unstable.neovim-unwrapped;
      viAlias = true;
      vimAlias = true;
      extraConfig = "
      	luafile ~/.config/nvim/user.lua
      ";
      plugins = with pkgs.vimPlugins;
        let
          fetchPluginFromGit = name: ref: pkgs.vimUtils.buildVimPluginFrom2Nix {
            name = name;
            src = builtins.fetchGit {
              url = "https://github.com/${name}";
              submodules = true;
              inherit ref;
            };
          };
        in [
          (fetchPluginFromGit  "LnL7/vim-nix" "HEAD")
          (fetchPluginFromGit  "tpope/vim-fugitive" "HEAD")
          (fetchPluginFromGit  "sainnhe/gruvbox-material" "HEAD")
          (fetchPluginFromGit  "nvim-treesitter/nvim-treesitter" "HEAD")
          (fetchPluginFromGit  "mvinkio/tnychain" "HEAD")
          (fetchPluginFromGit  "L3MON4D3/LuaSnip" "HEAD")
          (fetchPluginFromGit  "Furkanzmc/firvish.nvim" "HEAD")
          (fetchPluginFromGit  "folke/trouble.nvim" "HEAD")
          (fetchPluginFromGit  "klen/nvim-test" "HEAD")
          (fetchPluginFromGit  "neovim/nvim-lspconfig" "HEAD")
          (fetchPluginFromGit  "mfussenegger/nvim-dap" "HEAD")
          (fetchPluginFromGit  "rcarriga/nvim-dap-ui" "HEAD")
          (fetchPluginFromGit  "tjdevries/nlua.nvim" "HEAD")
          (fetchPluginFromGit  "jose-elias-alvarez/null-ls.nvim" "HEAD")
          (fetchPluginFromGit  "nvim-lua/plenary.nvim" "HEAD")
          (fetchPluginFromGit  "ray-x/lsp_signature.nvim" "HEAD")
          (fetchPluginFromGit  "justinmk/vim-dirvish" "HEAD")
        ];
    };
}
