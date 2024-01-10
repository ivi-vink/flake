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
    dns = {
      url = "github:kirelagin/dns.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-23.05";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
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
    mkSystem = machine: machineConfig: with lib;
    lib.nixosSystem {
      inherit lib system;
      specialArgs = {inherit self machine inputs;};
      modules = with lib;
        machine.modules
        ++ machineConfig
        ++ [({ config, ... }: {
             nixpkgs.overlays = with lib; [(composeManyExtensions [
               (import ./overlays/vimPlugins.nix {inherit pkgs;})
               inputs.neovim-nightly-overlay.overlay
             ])];})
           ];
    };

  in with lib; {
    inherit lib;
    nixosConfigurations = with lib;
      mapAttrs
        (hostname: cfg:
            mkSystem ivi.machines.${hostname} [cfg])
        (modulesIn ./machines)
      // {
           windows = windowsModules:
             let
               wsl = recursiveUpdate ivi.machines.wsl {modules = ivi.machines.wsl ++ windowsModules;};
             in
               (mkSystem wsl []);
           iso = (mkSystem { modules = [./iso.nix]; } []);
         };

    deploy.nodes =
      mapAttrs
      (hostname: machine: {
        hostname = hostname + "." + ivi.domain;
        sshUser = "root";
        profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.${hostname};
      })
      (filterAttrs (_: machine: machine.isServer) ivi.machines);

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
      (name: type: {path = ./templates + "/${name}";})
      (builtins.readDir ./templates);
  };
}
