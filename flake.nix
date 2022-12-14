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
    system = "x86_64-linux";
    mvinkioPkgs = mvinkio.legacyPackages.${system};

    overlay = nixpkgs.lib.composeManyExtensions [
      (import ./overlays/treesitter.nix {inherit mvinkioPkgs;})
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

    homeConfigurations.mike = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./home.nix
      ];

      extraSpecialArgs = {
        flake = self;
        home-manager = home-manager;
      };
    };
  };
}
