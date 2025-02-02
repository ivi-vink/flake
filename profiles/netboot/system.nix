sys: { pkgs, lib, ... }: let
  run-pixiecore = let
      build = sys.config.system.build;
    in pkgs.writeShellApplication {
      name = "run-pixiecore";
      text = ''
        sudo ${pkgs.pixiecore}/bin/pixiecore \
          boot ${build.kernel}/bzImage ${build.netbootRamdisk}/initrd \
          --cmdline "init=${build.toplevel}/init loglevel=4" \
          --debug --dhcp-no-bind \
          --port 64172 --status-port 64172 "$@"
      '';
    };
in {
  networking.firewall.allowedUDPPorts = [ 67 69 4011 ];
  networking.firewall.allowedTCPPorts = [ 64172 ];
  environment.systemPackages = [
    run-pixiecore
  ];
}
