{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    home-manager,
    sops-nix,
    ...
  }: let
    system = "x86_64-linux";
    overlay = nixpkgs.lib.composeManyExtensions [
      (import ./overlays/vimPlugins.nix {inherit pkgs;})
      (import ./overlays/suckless.nix {inherit pkgs;})
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
      modules = [
        ./nixos/configuration.nix
        ./nixos/lemptop.nix
      ] ++ (attrValues
        (attrsets.mergeAttrsList [
          (modulesIn ./profiles/core)
          (modulesIn ./profiles/station)
          (modulesIn ./profiles/email)
        ]));
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
