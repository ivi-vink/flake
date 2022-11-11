{
  description = "Home Manager configuration of Jane Doe";

  # Specify the source of Home Manager and Nixpkgs and vim plugins.
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-22.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    ...
  }: let
    system = "x86_64-linux";
    overlay = nixpkgs.lib.composeManyExtensions [
      (final: prev: {
        vimPlugins =
          prev.vimPlugins
          // {
            nvim-treesitter = prev.vimPlugins.nvim-treesitter.overrideAttrs (old: {
              version = "2022-10-28";
              src = builtins.fetchGit {
                url = "file:///home/mike/projects/nvim-treesitter";
                rev = "2c0ae6e8e81366ba088f1e5be62f467212cda52e";
              };
              passthru.withPlugins = grammarFn:
                final.vimPlugins.nvim-treesitter.overrideAttrs (_: {
                  postPatch = let
                    grammars = prev.tree-sitter.withPlugins grammarFn;
                  in ''
                    rm -r parser
                    ln -s ${grammars} parser
                  '';
                });
            });
          };
      })

      # fetchPluginFromGit = name: rev: pkgs.vimUtils.buildVimPluginFrom2Nix {
      #   name = name;
      #   src = builtins.fetchGit {
      #     url = "https://github.com/${name}";
      #     submodules = true;
      #     inherit rev;
      #   };
      # };

      # (fetchPluginFromGit  "klen/nvim-test" "32f162c27045fc712664b9ddbd33d3c550cb2bfc")

      (final: prev: {
        vimPlugins =
          prev.vimPlugins
          // {
            firvish-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
              name = "firvish-nvim";
              src = builtins.fetchGit {
                url = "https://github.com/Furkanzmc/firvish.nvim";
                submodules = true;
                rev = "127f9146175d6bbaff6a8b761081cfd2279f8351";
              };
            };
          };
      })
    ];

    pkgs = import nixpkgs {
      overlays = [
        overlay
      ];
      inherit system;
    };
  in {
    homeConfigurations.mike = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      # Specify your home configuration modules here, for example,
      # the path to your home.nix.
      modules = [
        ./home.nix
      ];

      # Optionally use extraSpecialArgs
      # to pass through arguments to home.nix
      extraSpecialArgs = {
        flake = self;
      };
    };
  };
}
