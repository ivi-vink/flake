# https://github.com/mitchellh/nixos-config/blob/main/machines/vm-aarch64-prl.nix
{ self, config, pkgs, lib, ... }: {
  imports =
    [ (self + "/profiles/vmware-guest.nix")
    ];
  system.stateVersion = "24.05";
  virtualisation.vmware.guest.enable = true;
  virtualisation.docker.enable = true;
  networking.hostName = "vm-aarch64";

  hm.xsession.initExtra = ''
      ${pkgs.xorg.xset}/bin/xset r rate 230 30
      [ -z "$(lsusb | grep microdox)" ] && ${pkgs.xorg.setxkbmap}/bin/setxkbmap -option "ctrl:swapcaps"
      ${pkgs.open-vm-tools}/bin/vmware-user-suid-wrapper
      wal -R
      dwm
  '';
  environment.systemPackages = with pkgs; [
    kubernetes-helm
    azure-cli
    awscli2
    (google-cloud-sdk.withExtraComponents (with google-cloud-sdk.components; [
      gke-gcloud-auth-plugin
    ]))
  ];

  services.pcscd.enable = true;
  sops.age.keyFile = "${config.hm.xdg.configHome}/sops/age/keys.txt";
  users.users.${lib.ivi.username} = {
    shell = pkgs.zsh;
  };
  environment.shells = [pkgs.bashInteractive pkgs.zsh];
  environment.pathsToLink = [ "/share/zsh" ];
  programs.zsh.enable = true;

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.PermitRootLogin = "yes";

  # Setup qemu so we can run x86_64 binaries
  boot.binfmt.emulatedSystems = ["x86_64-linux"];

  # Disable the default module and import our override. We have
  # customizations to make this work on aarch64.
  disabledModules = [ "virtualisation/vmware-guest.nix" ];

  # Interface is this on M1
  networking.interfaces.ens160.useDHCP = true;

  # Lots of stuff that uses aarch64 that claims doesn't work, but actually works.
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;

  # This works through our custom module imported above
  # virtualisation.vmware.guest.enable = true;

  # Share our host filesystem
  # fileSystems."/host" = {
  #   fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
  #   device = ".host:/";
  #   options = [
  #     "umask=22"
  #     "uid=1000"
  #     "gid=1000"
  #     "allow_other"
  #     "auto_unmount"
  #     "defaults"
  #   ];
  # };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # VMware, Parallels both only support this being 0 otherwise you see
  # "error switching console mode" on boot.
  boot.loader.systemd-boot.consoleMode = "0";

  # Hardware
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/boot";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.ens160.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
