{ config, pkgs, lib, modulesPath, ... }: with lib; {
  imports = [
    (modulesPath + "/installer/netboot/netboot-minimal.nix")
  ];
  services.getty.autologinUser = lib.mkForce "root";
  users.users.root.openssh.authorizedKeys.keys = my.sshKeys;

  services.openssh.enable = true;
  sops.age.keyFile = "${config.my.home}/sops/age/keys.txt";
  services.syncthing = {
    cert = builtins.toFile "syncthing-cert" ''
      -----BEGIN CERTIFICATE-----
      MIICGzCCAaKgAwIBAgIIRGieK4FEhD0wCgYIKoZIzj0EAwIwSjESMBAGA1UEChMJ
      U3luY3RoaW5nMSAwHgYDVQQLExdBdXRvbWF0aWNhbGx5IEdlbmVyYXRlZDESMBAG
      A1UEAxMJc3luY3RoaW5nMB4XDTI0MDIxMTAwMDAwMFoXDTQ0MDIwNjAwMDAwMFow
      SjESMBAGA1UEChMJU3luY3RoaW5nMSAwHgYDVQQLExdBdXRvbWF0aWNhbGx5IEdl
      bmVyYXRlZDESMBAGA1UEAxMJc3luY3RoaW5nMHYwEAYHKoZIzj0CAQYFK4EEACID
      YgAEH/4taBY2lcNBXZCxNOklTahIlhN+ypYMOqw7LNlKZVdv7JzRR67akp/F99mF
      PA+IB1CQoPOTXUjnhm84Tob/8MoUA1jM5uspclxXG95eMw2J7E7svBEGJA2RsEQE
      dsU3o1UwUzAOBgNVHQ8BAf8EBAMCBaAwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsG
      AQUFBwMCMAwGA1UdEwEB/wQCMAAwFAYDVR0RBA0wC4IJc3luY3RoaW5nMAoGCCqG
      SM49BAMCA2cAMGQCMCP0Ro0ZjGfQf9R3x3neKZzrJxkD11ZK9NBNTaeWAKbrhkjp
      qqW9uTONfIOXZmgtrQIwf6Ykr934UA5I6Rk8qNV8d082n3FNMw1NgK9GmUv2XMZ5
      eOpDAYJrhLx5jb7d3L4/
      -----END CERTIFICATE-----
    '';
  };

  networking.hostName = "pump";
  networking.domain = "vinkies.net";

  networking.hostId = "7da046cb";
  netboot.storeContents = [];

  # boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.initrd.availableKernelModules = [ "e1000e" ];
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true; # Use a different port than your usual SSH port!
      port = 2222;
      hostKeys = [
        (/. + "${config.my.home}" + "/.ssh/initrd/key")
      ];
      authorizedKeys = my.sshKeys;
    };
    postCommands = ''
      echo "zfs load-key -a; killall zfs" >> /root/.profile
    '';
  };

  fileSystems."/data" =
    { device = "zpool/data";
      fsType = "zfs";
    };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = config.system.nixos.release;
  nix.extraOptions = mkForce ''
    experimental-features = nix-command flakes
  '';
  nix.package = mkForce pkgs.nixVersions.stable;
}
