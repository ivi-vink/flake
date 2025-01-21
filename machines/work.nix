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
    };
    security = {
      sudo.wheelNeedsPassword = mkSinkUndeclaredOptions {};
    };
    systemd = mkSinkUndeclaredOptions {};
    users.users = mkOption {
      type = types.attrsOf (types.submodule ({...}: {
        options = {
          extraGroups = mkSinkUndeclaredOptions {};
          isNormalUser = mkSinkUndeclaredOptions {};
        };
        config = {
          home = "/Users/${my.username}";
        };
      }));
    };
  };
  config = {
    fonts = {
      packages = with pkgs; [
        nerd-fonts.fira-code
        nerd-fonts.jetbrains-mono
      ];
    };
    users.users.root.home = mkForce "/var/root";
    # List packages installed in system profile. To search by name, run:
    # $ nix-env -qaP | grep wget
    environment.systemPackages =
      [
        pkgs.nushell
        pkgs.zsh
        pkgs.bashInteractive
        pkgs.just
     ];
    hm = {
      # services.ssh-agent.enable = true;
      home = {
        sessionPath = [
          "/opt/homebrew/bin"
        ];
        # file.".config/aerospace".source = config.lib.meta.mkMutableSymlink /mut/aerospace;
        # file."Library/KeyBindings/DefaultKeyBinding.dict".source = config.lib.meta.mkMutableSymlink /mut/DefaultKeyBinding.dict;
        file."gpg-agent.conf" = {
          text = ''
            pinentry-program /opt/homebrew/bin/pinentry-mac
            enable-ssh-support
            ttyname $GPG_TTY
            default-cache-ttl 60
            max-cache-ttl 120
          '';
          target = ".gnupg/gpg-agent.conf";
        };
      };
    };

    networking.hostName = "work";
    sops.age.keyFile = "${config.hm.xdg.configHome}/sops/age/keys.txt";
    homebrew = {
      enable = true;
      brews = [
        "pinentry-mac"
      ];
      casks = [
        "docker"
        "intellij-idea-ce"
        "visual-studio-code"
        "zed"
      ];
      masApps = {
        tailscale = 1475387142;
        slack = 803453959;
      };
    };
    services.openssh.enable = false;
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
    my.shell = pkgs.nushell;

    environment.shells = [pkgs.bashInteractive pkgs.zsh pkgs.nushell];
    environment.pathsToLink = [ "/share/zsh" ];
    environment.variables = {
      SLACK_NO_AUTO_UPDATES = "1";
    };
  };
}
