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
    # List packages installed in system profile. To search by name, run:
    # $ nix-env -qaP | grep wget
    environment.systemPackages =
      [ # pkgs.qemu
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
      enable = false;
      skhdConfig = ''
        cmd - 1 : yabai -m space --focus 1
        cmd - 2 : yabai -m space --focus 2
        cmd - 3 : yabai -m space --focus 3
        cmd - 4 : yabai -m space --focus 4
        cmd - 5 : yabai -m space --focus 5
        cmd - 6 : yabai -m space --focus 6
        cmd - 7 : yabai -m space --focus 7
        cmd - 0x2F : yabai -m display --focus next || yabai -m display --focus first

        cmd - h : yabai -m window --resize right:-40:0 2> /dev/null || yabai -m window --resize left:-40:0 2> /dev/null
        cmd - l : yabai -m window --resize right:40:0 2> /dev/null || yabai -m window --resize left:40:0 2> /dev/null
        cmd - k : ${pkgs.writers.writeBash "cycle_cclockwise" ''
          if ! yabai -m window --focus prev &>/dev/null; then
            yabai -m window --focus last
          fi
        ''}
        cmd - j : ${pkgs.writers.writeBash "cycle_clockwise" ''
          if ! yabai -m window --focus next &>/dev/null; then
            yabai -m window --focus first
          fi
        ''}
        cmd + shift - k : ${pkgs.writers.writeBash "swap_cclockwise" ''
          win=$(yabai -m query --windows --window first | jq '.id')

          while : ; do
              yabai -m window $win --swap next &> /dev/null
              if [[ $? -eq 1 ]]; then
                  break
              fi
          done
        ''}
        cmd + shift - j : ${pkgs.writers.writeBash "swap_clockwise" ''
          win=$(yabai -m query --windows --window last | jq '.id')

          while : ; do
              yabai -m window $win --swap prev &> /dev/null
              if [[ $? -eq 1 ]]; then
                  break
              fi
          done
        ''}
        cmd - w [
          "Google Chrome" ~
          * : /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome
        ]
        cmd - e : osascript -e 'tell application "mail" to activate'
        cmd - m : osascript -e 'tell application "Slack" to activate'
        cmd + shift - m : osascript -e 'tell application "Microsoft Teams (work or school)" to activate'
        cmd - q : yabai -m window --close
        cmd + shift - r : /Applications/Alacritty.app/Contents/MacOS/alacritty -e htop
        cmd - return : /Applications/Alacritty.app/Contents/MacOS/alacritty
        cmd - space : ${pkgs.writers.writeBash "swap_first_or_recent" ''
          yabai -m window --swap first || yabai -m window --swap recent
        ''}
        cmd + shift - space : yabai -m window --toggle float
        cmd + shift - p : ${pkgs.writers.writeBash "passautotype" ''
          shopt -s nullglob globstar

          dmenu="/opt/homebrew/bin/dmenu-mac"

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

              /Applications/Hammerspoon.app/Contents/Frameworks/hs/hs -c "hs.loadSpoon([[PassAutotype]]):autotype([[$password]])"
          ) >/tmp/debug 2>&1
        ''}
        cmd - d : /opt/homebrew/bin/dmenu-mac
        cmd + shift - d : ${pkgs.writers.writeBash "passmenu" ''
          shopt -s nullglob globstar

          dmenu="/opt/homebrew/bin/dmenu-mac"

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
    my.shell = pkgs.zsh;
    environment.shells = [pkgs.bashInteractive pkgs.zsh];
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
