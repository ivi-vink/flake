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
        pkgs.pywal
        # pkgs.qemu
        # pkgs.kitty
        pkgs.openssh
        # pkgs.python311
        # pkgs.mpv
        pkgs.kubelogin
        pkgs.zsh
        pkgs.bashInteractive
        # pkgs.awscli2
        pkgs.skhd
        # pkgs.act
        pkgs.yubikey-manager
        # pkgs.gomplate
        # pkgs.just
     ];
    hm = {
      home = {
        sessionPath = [
          "/opt/homebrew/bin"
        ];
        file."gpg-agent.conf" = {
          text = ''
            pinentry-program /opt/homebrew/bin/pinentry-mac
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
#         cmd - 1 : osascript -e 'tell application "alacritty" to activate'
#         cmd - 2 : osascript -e 'tell application "Google Chrome" to activate'
#         cmd - 3 : osascript -e 'tell application "slack" to activate'
#         cmd - 4 : osascript -e 'tell application "Microsoft Teams (work or school)" to activate'
#         cmd - 5 : osascript -e 'tell application "calendar" to activate'
#         cmd - 6 : osascript -e 'tell application "mail" to activate'
    services.skhd = {
      enable = true;
      skhdConfig = ''
        cmd - d : /opt/X11/bin/xrandr -s 2560x1664
      '';
    };
    services.sketchybar.enable = false;
    services.yabai = {
      enable = false;
      package = pkgs.yabai;
      enableScriptingAddition = true;
      config = {
        focus_follows_mouse          = "off";
        mouse_follows_focus          = "off";
        window_placement             = "first_child";
        window_opacity               = "off";
        window_opacity_duration      = "0.0";
        window_border                = "on";
        window_border_placement      = "inset";
        window_border_width          = 2;
        window_border_radius         = 3;
        active_window_border_topmost = "off";
        window_topmost               = "on";
        window_shadow                = "float";
        active_window_border_color   = "0xff5c7e81";
        normal_window_border_color   = "0xff505050";
        insert_window_border_color   = "0xffd75f5f";
        active_window_opacity        = "1.0";
        normal_window_opacity        = "1.0";
        split_ratio                  = "0.50";
        split_type                   = "horizontal";
        auto_balance                 = "off";
        mouse_modifier               = "fn";
        mouse_action1                = "move";
        mouse_action2                = "resize";
        layout                       = "bsp";
        window_origin_display        = "focused";
        display_arrangement_order    = "vertical";
        top_padding                  = 10;
        bottom_padding               = 10;
        left_padding                 = 10;
        right_padding                = 10;
        window_gap                   = 10;
      };

      extraConfig = ''
          # rules
          yabai -m rule --add app='System Settings' manage=off
          yabai -m rule --add app='alacritty' title='dap' display='2'

          # Any other arbitrary config here
          yabai -m signal --add event=window_destroyed action="yabai -m query --windows --window &> /dev/null || yabai -m window --focus recent || yabai -m window --focus first"
          yabai -m signal --add event=application_terminated action="yabai -m query --windows --window &> /dev/null || yabai -m window --focus recent || yabai -m window --focus first"
          yabai -m signal --add event=window_created action="yabai -m window --warp east"
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
    programs.zsh = {
      enable = true;
      shellInit = ''
        export PATH="''${PATH}:${config.my.home}/.local/bin"
      '';
    };
  };
}
