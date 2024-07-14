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
    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nix-darwin = {
      url = "path:/Users/ivi/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    sops-nix,
    deploy-rs,
    ...
  }: let
    lib =
      (nixpkgs.lib.extend
        (_: _: home-manager.lib)).extend
          (import ./lib inputs);
  in
    with lib; rec {
      inherit lib;
      nixosConfigurations = mkSystems {
        lemptop = {
          system = "x86_64-linux";
          modules =
            [
              ./machines/lemptop.nix
            ]
            ++ modulesIn ./profiles/core
            ++ modulesIn ./profiles/graphical
            ++ modulesIn ./profiles/station
            ++ modulesIn ./profiles/email
            ++ [
              (import ./profiles/netboot/system.nix nixosConfigurations.pump)
            ];
          opts = {
            isStation = true;
            syncthing = {
              enable = true;
              id = "TGRWV6Z-5CJ4KRI-4VDTIUE-UA5LQYS-3ARZGNK-KL7HGXP-352PB5Q-ADTV6Q2";
            };
          };
        };

        pump = {
          system = "x86_64-linux";
          modules =
            [
              ./machines/pump-netboot.nix
              ./profiles/core/configuration.nix
              ./profiles/core/syncthing.nix
              ./profiles/core/secrets.nix
              ./profiles/core/hm.nix
            ]
            ++ modulesIn ./profiles/homeserver;
          opts = {
            isServer = true;
            ipv4 = [ "192.168.2.13" ];
            ipv6 = [ "2a02:a46b:ee73:1:c240:4bcb:9fc3:71ab" ];
            tailnet = {
              ipv4 = "100.90.145.95";
              ipv6 = "fd7a:115c:a1e0::e2da:915f";
              nodeKey = "nodekey:dcd737aab30c21eb4f44a40193f3b16a8535ffe2fb5008904b39bb54e2da915e";
            };
            syncthing = {
              enable = false;
              # id = "7USTCMT-QZTLGPL-5FCRKJW-BZUGMOS-H7D2TTK-F4COYPG-5D7VUO2-QFME2AS";
            };
          };
        };

        serber = {
          system = "x86_64-linux";
          modules =
            [
              ./machines/serber.nix
            ]
            ++ modulesIn ./profiles/core
            ++ modulesIn ./profiles/server;
          opts = {
            isServer = true;
            ipv4 = [ "65.109.143.65" ];
            ipv6 = [ "2a01:4f9:c012:ccc2::1" ];
          };
        };

        work = {
          system = "aarch64-darwin";
          modules =
            [
              ./machines/work.nix
            ]
            ++ modulesIn ./profiles/core;
          opts = {
            isDarwin = true;
            syncthing = {
              enable = true;
              id = "GR5MHK2-HDCFX4I-Y7JYKDN-EFTQFG6-24CXSHB-M5C6R3G-2GWX5ED-VEPAQA7";
            };
          };
        };

        vm-aarch64 = {
          system = "aarch64-linux";
          modules =
            [
              ./machines/vm-aarch64.nix
            ]
            ++ modulesIn ./profiles/core
            ++ modulesIn ./profiles/graphical;
          opts = {
            isStation = true;
            syncthing = {
              enable = true;
              id = "LDZVZ6H-KO3BKC6-FMLZOND-MKXI4DF-SNT27OT-Q5KMN2M-A2DYFNQ-3BWUYA6";
            };
          };
        };
      };

      deploy.nodes = {
        pump = {
          hostname = "192.168.2.13"; # hostname + "." + my.domain;
          sshUser = "root";
          profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.pump;
        };
      };

      devShells.x86_64-linux.hetzner = let
        pkgs = (import nixpkgs {system = "x86_64-linux";});
      in with pkgs; mkShell {
        name = "deploy";
        buildInputs = [
          pkgs.bashInteractive
          deploy-rs.packages."${system}".default
        ];
        shellHook = ''
          export HCLOUD_TOKEN="$(pass show personal/hetzner-token)"
        '';
      };

      # templates =
      #   mapAttrs
      #   (name: type: {path = ./templates + "/${name}";})
      #   (builtins.readDir ./templates);
    };
}
