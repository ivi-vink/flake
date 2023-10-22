{ modulesPath, config, pkgs, lib, ... }: with lib; {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  networking = {
    nameservers = [ "8.8.8.8" ];
    defaultGateway = "172.31.1.1";
    defaultGateway6 = { address = "fe80::1"; interface = "eth0"; };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          { address="65.108.155.179"; prefixLength=32; }
        ];
        ipv6.addresses = [
          { address="2a01:4f9:c010:d2b5::1"; prefixLength=64; }
          { address="fe80::9400:2ff:fe53:8544"; prefixLength=64; }
        ];
        ipv4.routes = [ { address = "172.31.1.1"; prefixLength = 32; } ];
        ipv6.routes = [ { address = "fe80::1"; prefixLength = 128; } ];
      };

    };
  };

  services.udev.extraRules = ''
    ATTR{address}=="96:00:02:53:85:44", NAME="eth0"
  '';

  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };

  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  system.stateVersion = "23.05";
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "vinkies";
  networking.domain = "net";
  services.openssh.enable = true;

}
