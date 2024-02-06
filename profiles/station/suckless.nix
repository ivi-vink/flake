{
  self,
  config,
  pkgs,
  lib,
  ...
}: with lib; {
  nixpkgs.overlays = [(import (self + "/overlays/suckless.nix") {inherit pkgs; home = config.ivi.home;})];
  hm = {
    xsession = {
      enable = false;
      initExtra = ''
      ${pkgs.xorg.xmodmap}/bin/xmodmap -e "remove mod1 = Alt_R"
      ${pkgs.xorg.xmodmap}/bin/xmodmap -e "add mod3 = Alt_R"
      wal -R
      dwm
      dwmblocks &
    '';
    };
    services.picom = {
      enable = false;
      activeOpacity = 0.99;
      inactiveOpacity = 0.7;
      opacityRules = [
        "100:class_g = 'Wfica'"
        "100:class_g = 'dwm'"
        "100:name *= 'Firefox'"
        "100:name *= 'mpv'"
        "100:name *= 'LibreWolf'"
        "100:name *= 'Steam'"
        "100:name *= 'Risk of Rain'"
        "100:name *= 'KVM'"
      ];
      settings = {
        inactive-opacity-override = false;
        frame-opacity = 1;
      };
    };
    services.dunst = {
      enable = false;
      settings = {
        global = {
          monitor = 0;
          follow = "keyboard";
          width = 370;
          height = 350;
          offset = "0x19";
          padding = 2;
          horizontal_padding = 2;
          transparency = 0;
          font = "Monospace 12";
          format = "<b>%s</b>\\n%b";
        };
        urgency_low = {
          background = "#1d2021";
          foreground = "#928374";
          timeout = 3;
        };
        urgency_normal = {
          foreground = "#ebdbb2";
          background = "#458588";
          timeout = 5;
        };
        urgency_critical = {
          background = "#1cc24d";
          foreground = "#ebdbb2";
          frame_color = "#fabd2f";
          timeout = 10;
        };
      };
    };
    home.packages = with pkgs; [
      # st
      # dwm
      # dwmblocks
      libnotify
    ];
  };
}
