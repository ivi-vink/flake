sys: { pkgs, lib, ... }: let
  run-pixiecore = let
      build = sys.config.system.build;
    in pkgs.writeShellApplication {
      name = "run-pixiecore";
      text = ''
        sudo ${pkgs.pixiecore}/bin/pixiecore \
          boot kernel/bzImage initrd/initrd \
          --cmdline "init=init/init loglevel=4" \
          --debug --dhcp-no-bind \
          --port 64172 --status-port 64172 "$@"
      '';
    };
  build-pixie = pkgs.writeShellApplication {
      name = "build-pixie";
      text = ''
        nix build /nix-config\#nixosConfigurations."$1".config.system.build.kernel --impure -o kernel
        nix build /nix-config\#nixosConfigurations."$1".config.system.build.toplevel --impure -o init
        nix build /nix-config\#nixosConfigurations."$1".config.system.build.netbootRamdisk --impure -o initrd
      '';
    };
in {
  networking.firewall.allowedUDPPorts = [ 67 69 4011 ];
  networking.firewall.allowedTCPPorts = [ 64172 ];
  environment.systemPackages = [
    run-pixiecore
    build-pixie
  ];
}
