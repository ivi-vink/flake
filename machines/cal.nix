{ modulesPath, config, pkgs, lib, ... }: with lib; {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };

  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  system.stateVersion = "23.11";
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "vinkies";
  networking.domain = "net";
  services.openssh.enable = true;
}
