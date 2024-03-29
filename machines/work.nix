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
        pkgs.kubelogin
        pkgs.zsh
        pkgs.bashInteractive
        pkgs.awscli2
      ];
    hm.home.sessionPath = [
      "/opt/homebrew/bin"
    ];
    hm = {
      programs.kitty = {
        enable = true;
        shellIntegration = {
          enableZshIntegration = true;
        };
        extraConfig = ''
          cursor_shape block
          font_family      JetBrainsMono Nerd Font Mono
          text_composition_strategy platform
          cursor_blink_interval 0
          draw_minimal_borders yes
          hide_window_decorations no
          confirm_os_window_close 0
          macos_option_as_alt yes
          linux_display_server x11

          clear_all_shortcuts yes
          kitty_mod alt
          mouse_map right press ungrabbed mouse_select_command_output
          map kitty_mod+v mouse_select_command_output
          scrollback_pager less --chop-long-lines --RAW-CONTROL-CHARS +INPUT_LINE_NUMBER

          map kitty_mod+k scroll_to_prompt -1
          map kitty_mod+j scroll_to_prompt 1
          map kitty_mod+l show_last_visited_command_output
          map kitty_mod+shift+l show_scrollback

          map kitty_mod+w>p show_last_visited_command_output
          map kitty_mod+w>shift+p show_first_command_output_on_screen

          map kitty_mod+w>_ toggle_layout stack
          map kitty_mod+w>= goto_layout fat
          map kitty_mod+w>g goto_layout grid

          map kitty_mod+w>c close_window
          map kitty_mod+w>j neighboring_window bottom
          map kitty_mod+w>k neighboring_window top
          map kitty_mod+w>h neighboring_window left
          map kitty_mod+w>l neighboring_window right
          map kitty_mod+w>e open_url_with_hints
          map kitty_mod+w>space move_window_to_top
          map kitty_mod+w>shift+k move_window_forward
          map kitty_mod+w>shift+j move_window_backward

          map kitty_mod+enter new_window
          map kitty_mod+r load_config_file
          map cmd+c copy_to_clipboard
          map cmd+v paste_from_clipboard

          ## name: Kanagawa
          ## license: MIT
          ## author: Tommaso Laurenzi
          ## upstream: https://github.com/rebelot/kanagawa.nvim/


          background #1F1F28
          foreground #DCD7BA
          selection_background #2D4F67
          selection_foreground #C8C093
          url_color #72A7BC
          cursor #C8C093

          # Tabs
          active_tab_background #1F1F28
          active_tab_foreground #C8C093
          inactive_tab_background  #1F1F28
          inactive_tab_foreground #727169
          #tab_bar_background #15161E

          # normal
          color0 #16161D
          color1 #C34043
          color2 #76946A
          color3 #C0A36E
          color4 #7E9CD8
          color5 #957FB8
          color6 #6A9589
          color7 #C8C093

          # bright
          color8  #727169
          color9  #E82424
          color10 #98BB6C
          color11 #E6C384
          color12 #7FB4CA
          color13 #938AA9
          color14 #7AA89F
          color15 #DCD7BA


          # extended colors
          color16 #FFA066
          color17 #FF5D62
        '';
      };
    };

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
        cmd - 1 : osascript -e 'tell application "kitty" to activate'
        cmd - 2 : osascript -e 'tell application "Google Chrome" to activate'
        cmd - 3 : osascript -e 'tell application "slack" to activate'
        cmd - 4 : osascript -e 'tell application "Microsoft Teams (work or school)" to activate'
        cmd - 5 : osascript -e 'tell application "calendar" to activate'
        cmd - 6 : osascript -e 'tell application "mail" to activate'
        cmd + shift - d : ${pkgs.writers.writeBash "passmenu" ''
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
      shell = pkgs.zsh;
    };
    environment.shells = [pkgs.bashInteractive pkgs.zsh];
    environment.pathsToLink = [ "/share/zsh" ];
    programs.zsh.enable = true;
  };
}
