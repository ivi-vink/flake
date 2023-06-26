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
    email = builtins.getEnv "EMAIL";
    system = "x86_64-linux";
    mvinkioPkgs = mvinkio.legacyPackages.${system};

    overlay = nixpkgs.lib.composeManyExtensions [
      (import ./overlays/vimPlugins.nix {inherit pkgs;})
      # (import ./overlays/fennel-language-server.nix {inherit pkgs;})
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
        ./home/suckless.nix
        ./home/neovim.nix
        ./home/codeium.nix
        ./home/packages.nix
        ./home/newsboat.nix
        ./home/kakoune.nix
        ./home/mpv.nix
      ];
      extraSpecialArgs = {
        inherit home-manager username email;
      };
    };

    templates = {
      default = {
        path = ./templates/flake;
        description = "Flake with python and go stuff";
      };
      ansible = {
        path = ./templates/ansible;
        description = "Flake with ansible and shellhook to login to awx";
      };
      go = {
        path = ./templates/go;
        description = "Flake with go, gotools, and gofumpt";
      };
    };
  };
}
