{
  description = "Home Manager configuration of Jane Doe";

  # Specify the source of Home Manager and Nixpkgs and vim plugins.
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    mvinkio.url = "github:mvinkio/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-22.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    mvinkio,
    nixpkgs-stable,
    home-manager,
    ...
  }: let
    system = "x86_64-linux";
    mvinkioPkgs = mvinkio.legacyPackages.${system};
    overlay = nixpkgs.lib.composeManyExtensions [
      (final: prev: {
        tree-sitter = mvinkioPkgs.tree-sitter;
        vimPlugins =
          prev.vimPlugins
          // {
            nvim-treesitter = mvinkioPkgs.vimPlugins.nvim-treesitter.overrideAttrs (old: {
              version = "2022-10-28";
              src = builtins.fetchGit {
                url = "file:///home/mike/projects/nvim-treesitter";
                rev = "2c0ae6e8e81366ba088f1e5be62f467212cda52e";
              };
              passthru.withPlugins = grammarFn:
                final.vimPlugins.nvim-treesitter.overrideAttrs (_: {
                  postPatch = let
                    grammars = mvinkioPkgs.tree-sitter.withPlugins grammarFn;
                  in ''
                    rm -r parser
                    ln -s ${grammars} parser
                  '';
                });
            });
          };
      })

      # overlay some vim plugins
      (final: prev: {
        vimPlugins = let
          getVimPlugin = {
            name,
            git,
            rev,
            ref ? "master",
          }:
            pkgs.vimUtils.buildVimPluginFrom2Nix {
              inherit name;
              src = builtins.fetchGit {
                url = "https://github.com/${git}";
                submodules = true;
                inherit rev;
                inherit ref;
              };
            };
        in
          prev.vimPlugins
          // {
            firvish-nvim = getVimPlugin {
              name = "firvish-nvim";
              git = "Furkanzmc/firvish.nvim";
              rev = "127f9146175d6bbaff6a8b761081cfd2279f8351";
            };
            nvim-parinfer = getVimPlugin {
              name = "nvim-parinfer";
              git = "gpanders/nvim-parinfer";
              rev = "82bce5798993f4fe5ced20e74003b492490b4fe8";
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
