{
  description = "Home Manager configuration";

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
    username = builtins.getEnv "USER";
    system = "x86_64-linux";
    mvinkioPkgs = mvinkio.legacyPackages.${system};

    overlay = nixpkgs.lib.composeManyExtensions [
      (import ./overlays/vimPlugins.nix {inherit pkgs;})
    ];

    pkgs = import nixpkgs {
      overlays = [
        overlay
      ];
      inherit system;
    };
  in {
    nixosConfigurations.lemptop = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [./configuration.nix ./lemptop.nix];
    };

    homeConfigurations.mvinkio = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./home.nix
        ./home/st.nix
        ./home/neovim.nix
        ./home/codeium.nix
        ./home/packages.nix
      ];
      extraSpecialArgs = {
        home-manager = home-manager;
        username = username;
      };
    };

    templates.default = {
      path = ./templates/flake;
      description = "nix flake new -t ~/flake";
    };
  };
}
