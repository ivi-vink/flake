{
  description = "Nixos, home-manager, and deploy-rs configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs.url = "github:serokell/deploy-rs";
    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-23.05";
  };

  outputs = inputs@{
    self,
    nixpkgs,
    home-manager,
    sops-nix,
    deploy-rs,
    ...
  }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
    lib = (nixpkgs.lib.extend (_: _: home-manager.lib)).extend (import ./ivi self);

    # Gets module from ./machines/ and uses the lib to define which other modules
    # the machine needs.
    mkSystem = name: machineConfig: with lib;
    let
        machine = ivi.machines.${name};
    in
    nixosSystem {
      inherit lib system;
      specialArgs = {inherit machine inputs;};
      modules = with lib;
        machine.modules
        ++ [machineConfig]
        ++ [({ config, ... }: {
             nixpkgs.overlays = with lib; [(composeManyExtensions [
               (import ./overlays/vimPlugins.nix {inherit pkgs;})
               (import ./overlays/suckless.nix {inherit pkgs; home = config.ivi.home;})
             ])];})
           ];
    };

  in with lib; {
    inherit lib;
    nixosConfigurations = with lib;
      (mapAttrs mkSystem (modulesIn ./machines)) // {
          windows = modules:
            nixosSystem "wsl" ({...}: {
              imports = modules;
            });
      };

    deploy.nodes =
      mapAttrs
      (hostname: machine: {
        hostname = hostname + "." + ivi.domain;
        sshUser = "root";
        profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.${hostname};
      })
      (filterAttrs (_: machine: machine.isDeployed) ivi.machines);

    devShells."${system}".hetzner = pkgs.mkShell {
      name = "deploy";
      buildInputs = [
          pkgs.bashInteractive
          deploy-rs.packages."${system}".default
      ];
      shellHook = ''
          export HCLOUD_TOKEN="$(pass show personal/hetzner-token)"
      '';
    };

    templates =
      mapAttrs
      (templateName: path: {inherit path;})
      (modulesIn ./templates);
  };
}
