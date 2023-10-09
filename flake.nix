{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    home-manager,
    sops-nix,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
    lib = (nixpkgs.lib.extend (_: _: home-manager.lib)).extend (import ./lib);
  in with lib; {
    inherit lib;

    nixosConfigurations.lemptop = nixpkgs.lib.nixosSystem {
      inherit lib system;
      specialArgs = {inherit inputs;};
      modules = [
        ({config, ... }: {
          nixpkgs.overlays = with lib; [(composeManyExtensions [
            (import ./overlays/vimPlugins.nix {inherit pkgs;})
            (import ./overlays/suckless.nix {inherit pkgs; home = config.users.users.mike.home;})
          ])];
        })
        ./machines/lemptop.nix
      ] ++ (attrValues
        (attrsets.mergeAttrsList (map modulesIn [
          ./profiles/core
          ./profiles/station
          ./profiles/email
        ])));
    };

    nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
      inherit lib system;
      specialArgs = {inherit inputs;};
      modules = [
        ({config, ... }: {
          nixpkgs.overlays = with lib; [(composeManyExtensions [
            (import ./overlays/vimPlugins.nix {inherit pkgs;})
            (import ./overlays/suckless.nix {inherit pkgs; home = config.users.users.mike.home;})
          ])];
        })
        ./machines/wsl.nix
      ] ++ (attrValues
        (attrsets.mergeAttrsList (map modulesIn [
          ./profiles/core
          ./profiles/station
        ])));
    };

    templates = {
      default = {
        path = ./templates/flake;
        description = "Python and go stuff";
      };
      ansible = {
        path = ./templates/ansible;
        description = "Ansible and shellhook to login to awx";
      };
      go = {
        path = ./templates/go;
        description = "Go, gotools, and gofumpt";
      };
    };
  };
}
