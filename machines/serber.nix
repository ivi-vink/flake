{ modulesPath, lib, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  services.syncthing.enable = false;

  environment.etc."resolv.conf".source = lib.mkForce "/run/systemd/resolve/resolv.conf";
  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];
    dnsovertls = "true";
  };

  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
    defaultGateway = "172.31.1.1";
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eth0";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          { address="65.109.143.65"; prefixLength=32; }
        ];
        ipv6.addresses = [
          { address="2a01:4f9:c012:ccc2::1"; prefixLength=64; }
          { address="fe80::9400:3ff:fe46:c7bc"; prefixLength=64; }
        ];
        ipv4.routes = [ { address = "172.31.1.1"; prefixLength = 32; } ];
        ipv6.routes = [ { address = "fe80::1"; prefixLength = 128; } ];
      };
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="96:00:03:46:c7:bc", NAME="eth0"

  '';

  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "serber";
  networking.domain = "";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [''sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPZHOBNQdo5oBnQ8f147QtelhLmYItiruoNfoHF89qrJAAAABHNzaDo='' ];
  system.stateVersion = "23.11";
}
