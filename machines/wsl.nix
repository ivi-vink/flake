{ inputs, config, lib, pkgs, ... }:
with builtins; with lib;
let
  defaultConfig = pkgs.writeText "default-configuration.nix" ''
    { config, lib, pkgs, ... }:

    {
      imports = [
        # include NixOS-WSL modules
        <nixos-wsl/modules>
      ];

      wsl.enable = true;
      wsl.defaultUser = "nixos";
      environment.systemPackages = with pkgs; [
        git
      ];

      system.stateVersion = "23.05";
      virtualisation.docker = {
          enable = true;
          autoPrune = {
              enable = true;
              flags = ["-af"];
          };
      };
      systemd.services.docker.serviceConfig = {
          ExecStart = ["" $'$'
              ${pkgs.docker}/bin/dockerd --config-file=/wsl/dockerd/daemon.json
          $'$'];
          EnvironmentFile = "/wsl/dockerd/environmentfile";
      };
      # TODO: why does this not work with just etc."resolv.conf"??
      environment.etc."/resolv.conf".source = "/wsl/etc/resolv.conf";
      environment.etc."profile.local".source = "/wsl/etc/profile";
      security.pki.certificateFiles = [
          (/. + "/wsl/pr-root.cer")
      ];
      system.stateVersion = "${config.system.nixos.release}";
    }
  '';
in

{
  imports = [
      inputs.nixos-wsl.nixosModules.default
  ];

  # These options make no sense without the wsl-distro module anyway
  config = {
    wsl = {
        enable = true;
        defaultUser = "mike";
        wslConf.network = {
            generateResolvConf = false;
        };
    };

    system.build.tarballBuilder = pkgs.writeShellApplication {
      name = "nixos-wsl-tarball-builder";

      runtimeInputs = [
        pkgs.coreutils
        pkgs.gnutar
        pkgs.nixos-install-tools
        config.nix.package
      ];

      text = ''
        if ! [ $EUID -eq 0 ]; then
          echo "This script must be run as root!"
          exit 1
        fi

        out=''${1:-nixos-wsl.tar.gz}

        root=$(mktemp -p "''${TMPDIR:-/tmp}" -d nixos-wsl-tarball.XXXXXXXXXX)
        # FIXME: fails in CI for some reason, but we don't really care because it's CI
        trap 'rm -rf "$root" || true' INT TERM EXIT

        chmod o+rx "$root"

        echo "[NixOS-WSL] Installing..."
        nixos-install \
          --root "$root" \
          --no-root-passwd \
          --system ${config.system.build.toplevel} \
          --substituters ""

        echo "[NixOS-WSL] Adding channel..."
        nixos-enter --root "$root" --command 'nix-channel --add https://github.com/nix-community/NixOS-WSL/archive/refs/heads/main.tar.gz nixos-wsl'

        echo "[NixOS-WSL] Adding default config..."
        install -Dm644 ${defaultConfig} "$root/etc/nixos/configuration.nix"

        echo "[NixOS-WSL] Compressing..."
        tar -C "$root" \
          -cz \
          --sort=name \
          --mtime='@1' \
          --owner=0 \
          --group=0 \
          --numeric-owner \
          . \
          > "$out"
      '';
    };

    environment.systemPackages = with pkgs; [
      git
    ];

    system.stateVersion = "23.05";
    virtualisation.docker = {
        enable = true;
        autoPrune = {
            enable = true;
            flags = ["-af"];
        };
    };
    systemd.services.docker.serviceConfig = {
        ExecStart = ["" ''
            ${pkgs.docker}/bin/dockerd --config-file=/wsl/dockerd/daemon.json
        ''];
        EnvironmentFile = "/wsl/dockerd/environmentfile";
    };
    # TODO: why does this not work with etc."resolv.conf"??

    networking.resolvconf.enable = false;
    environment.etc."/resolv.conf".source = "/wsl/etc/resolv.conf";
    environment.etc."profile.local".source = "/wsl/etc/profile";
    security.pki.certificateFiles = [
        (/. + "/wsl/pr-root.cer")
    ];
  };
}
