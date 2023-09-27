{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    mvinkio.url = "github:mvinkio/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-22.05";
    sops-nix.url = "github:Mic92/sops-nix";
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    mvinkio,
    nixpkgs-stable,
    home-manager,
    sops-nix,
    ...
  }: let
    home = builtins.getEnv "HOME";
    username = builtins.getEnv "USER";
    email = builtins.getEnv "EMAIL";
    system = "x86_64-linux";
    mvinkioPkgs = mvinkio.legacyPackages.${system};

    overlay = nixpkgs.lib.composeManyExtensions [
      (import ./overlays/vimPlugins.nix {inherit pkgs;})
      (import ./overlays/suckless.nix {inherit pkgs home;})
    ];

    pkgs = import nixpkgs {
      overlays = [
        overlay
      ];
      inherit system;
    };

    lib = (nixpkgs.lib.extend (_: _: home-manager.lib)).extend (import ./lib);

  in with lib; {
    inherit lib;

    nixosConfigurations.lemptop = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [./configuration.nix ./lemptop.nix sops-nix.nixosModules.sops];
    };

    homeConfigurations.mike = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules =
        (attrValues
          (attrsets.mergeAttrsList [
            (modulesIn ./home)
            (modulesIn ./email)
          ])) ++ [./home.nix];
      extraSpecialArgs = {
        inherit inputs username email;
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
