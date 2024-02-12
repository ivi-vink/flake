{ self, config, pkgs, lib, ... }: with lib; {
  options = {
    virtualisation = mkSinkUndeclaredOptions {};
    programs = {
      virt-manager = mkSinkUndeclaredOptions {};
      steam = mkSinkUndeclaredOptions {};
    };
    hardware = mkSinkUndeclaredOptions {};
    services = {
      resolved = mkSinkUndeclaredOptions {};
      openssh.enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
    security = {
      sudo = mkSinkUndeclaredOptions {};
    };
    users.users = mkOption {
      type = types.attrsOf (types.submodule ({...}: {
        options = {
          extraGroups = mkSinkUndeclaredOptions {};
          isNormalUser = mkSinkUndeclaredOptions {};
        };
        config = {
          home = "/Users/${ivi.username}";
        };
      }));
    };
  };
  config = {
    # List packages installed in system profile. To search by name, run:
    # $ nix-env -qaP | grep wget
    environment.systemPackages =
      [ pkgs.qemu
        pkgs.kitty
        pkgs.openssh
        pkgs.python311
        pkgs.mpv
      ];
    hm.home.sessionPath = [
      "/opt/homebrew/bin"
    ];

    networking.hostName = "work";
    sops.age.keyFile = "${config.hm.xdg.configHome}/sops/age/keys.txt";
    homebrew = {
      enable = true;
      brews = [
        "choose-gui"
      ];
      casks = [
        "docker"
      ];
      masApps = {
        tailscale = 1475387142;
      };
    };
    services.syncthing = {
      cert = builtins.toFile "syncthing-cert" ''
        -----BEGIN CERTIFICATE-----
        MIICHDCCAaKgAwIBAgIICf/IfhEqojIwCgYIKoZIzj0EAwIwSjESMBAGA1UEChMJ
        U3luY3RoaW5nMSAwHgYDVQQLExdBdXRvbWF0aWNhbGx5IEdlbmVyYXRlZDESMBAG
        A1UEAxMJc3luY3RoaW5nMB4XDTI0MDIwOTAwMDAwMFoXDTQ0MDIwNDAwMDAwMFow
        SjESMBAGA1UEChMJU3luY3RoaW5nMSAwHgYDVQQLExdBdXRvbWF0aWNhbGx5IEdl
        bmVyYXRlZDESMBAGA1UEAxMJc3luY3RoaW5nMHYwEAYHKoZIzj0CAQYFK4EEACID
        YgAEB3N4kE5gTlpCt8W/ocQQbDZMvIzmNghcl0tsc+EVPXCTnpinIB48jOxGNkPr
        rm0o3EEPrI8O+cJqSydeyeSVMKYCjNswP6LiYNWaWua+SXjz25FurJxV21LXYMhc
        1egPo1UwUzAOBgNVHQ8BAf8EBAMCBaAwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsG
        AQUFBwMCMAwGA1UdEwEB/wQCMAAwFAYDVR0RBA0wC4IJc3luY3RoaW5nMAoGCCqG
        SM49BAMCA2gAMGUCMEOYa4HZKLy4WimWlAIpXU/joYvpIPS3dJP50VQIkKFj/eL8
        p8+rG7+7P03W7J4E6AIxANp5CxwCtTlh1a1+8Kdvfc7ZvFuMwPlM3d8EFk9y9aRZ
        jurkqKKyl7EUOk0ufvUaQQ==
        -----END CERTIFICATE-----
      '';
    };
    services.skhd = {
      enable = true;
      skhdConfig = ''
        cmd - return : ${pkgs.kitty}/bin/kitty --single-instance -d ~
        cmd + shift - return : ${pkgs.writers.writeBash "passmenu" ''
          shopt -s nullglob globstar

          dmenu="/opt/homebrew/bin/choose"

          (
              export PASSWORD_STORE_DIR="$HOME/sync/password-store"
              prefix="$PASSWORD_STORE_DIR"
              echo "prefix: $prefix"
              password_files=( "$prefix"/**/*.gpg )
              password_files=( "''${password_files[@]#"$prefix"/}" )
              password_files=( "''${password_files[@]%.gpg}" )
              echo "password_files: ''${password_files[*]}"

              password="$(printf '%s\n' "''${password_files[@]}" | "$dmenu" "$@")"
              echo "password: $password"

              [[ -n $password ]] || exit

              ${pkgs.pass}/bin/pass show -c "$password"
          ) >/tmp/debug 2>&1
        ''}
      '';
    };

    # Auto upgrade nix package and the daemon service.
    services.nix-daemon.enable = true;
    # nix.package = pkgs.nix;

    # Necessary for using flakes on this system.
    nix.settings.experimental-features = "nix-command flakes";

    nix.extraOptions = ''extra-platforms = x86_64-darwin aarch64-darwin '';

    # Set Git commit hash for darwin-version.
    system.configurationRevision = self.rev or self.dirtyRev or null;

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    system.stateVersion = 4;

    # The platform the configuration will be used on.
    nixpkgs.hostPlatform = "aarch64-darwin";
    users.users.${ivi.username} = {
      shell = pkgs.bashInteractive;
    };
    environment.shells = [pkgs.bashInteractive];
  };
}
