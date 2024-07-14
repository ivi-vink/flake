{ config, lib, pkgs, modulesPath, ... }:
with lib;
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];
  # networking.nameservers = ["192.168.2.13"];
  hm.xsession.initExtra = ''
      ${pkgs.xorg.xset}/bin/xset r rate 230 30
      [ -z "$(lsusb | grep microdox)" ] && ${pkgs.xorg.setxkbmap}/bin/setxkbmap -option "ctrl:swapcaps"
      wal -R
      dwm
  '';

  sops.age.keyFile = "${config.hm.xdg.configHome}/sops/age/keys.txt";
  services.tailscale.enable = true;
  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };
  services.syncthing = {
    cert = builtins.toFile "syncthing-cert" ''
      -----BEGIN CERTIFICATE-----
      MIICHDCCAaKgAwIBAgIIFZKAkMwT4FgwCgYIKoZIzj0EAwIwSjESMBAGA1UEChMJ
      U3luY3RoaW5nMSAwHgYDVQQLExdBdXRvbWF0aWNhbGx5IEdlbmVyYXRlZDESMBAG
      A1UEAxMJc3luY3RoaW5nMB4XDTI0MDIxMTAwMDAwMFoXDTQ0MDIwNjAwMDAwMFow
      SjESMBAGA1UEChMJU3luY3RoaW5nMSAwHgYDVQQLExdBdXRvbWF0aWNhbGx5IEdl
      bmVyYXRlZDESMBAGA1UEAxMJc3luY3RoaW5nMHYwEAYHKoZIzj0CAQYFK4EEACID
      YgAE3vRYSYSQ0ZRPG97Bo9m+0LMVGGiJ3/2I+QBaWHe+pDMh3nB7cOV04z9s2q7z
      MNjIsWYBPVUxIKFdIMfFN4svH2YpDt1Ps4AdfdPVUv/EsCIoyrtAc13Y64GJSKtF
      GFKao1UwUzAOBgNVHQ8BAf8EBAMCBaAwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsG
      AQUFBwMCMAwGA1UdEwEB/wQCMAAwFAYDVR0RBA0wC4IJc3luY3RoaW5nMAoGCCqG
      SM49BAMCA2gAMGUCMQDgWiqyibzhjXcbVVj0ZR8uITLTrZrrpUT13iiL674JK7uV
      DRY28bmdBaZXrOPvOgICMDq8lNeqdQ/jq5CCLe+KJZdtJ/E4XWtls3av09XP+DXK
      BtFKP2jvlC7HHtZMKManKQ==
      -----END CERTIFICATE-----
    '';
  };
  my.shell = pkgs.zsh;
  environment.shells = [pkgs.bashInteractive pkgs.zsh];
  environment.pathsToLink = [ "/share/zsh" ];
  programs.zsh.enable = true;

  documentation.dev.enable = true;
  networking.hostName = "lemptop";
  networking.networkmanager.enable = true;

  programs.slock.enable = true;
  services.xserver.enable = true;
  services.xserver.displayManager.startx.enable = true;
  services.xserver.libinput.enable = true;

  services.pcscd.enable = true;
  security.pam.services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
  };
  services.udev.packages = [ pkgs.yubikey-personalization ];
  services.udev.extraRules = ''
    # Yubico Yubikey II
    ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0010|0110|0111|0114|0116|0401|0403|0405|0407|0410", \
        ENV{ID_SECURITY_TOKEN}="1"

    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0200|0402|0403|0406|0407|0410", TAG+="uaccess"
  '';

  virtualisation.docker.enable = true;
  programs.nix-ld.enable = true;

  sound.enable = false;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  hardware.keyboard.qmk.enable = true;
  hardware.system76.enableAll = true;
  services.xserver.videoDrivers = [ "i915" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelParams = [ "i915.force_probe=46a8" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/08ed8d2d-38be-4019-9a84-dbded2cd0649";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/655D-8467";
      fsType = "vfat";
    };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

  system.stateVersion = "23.05";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
