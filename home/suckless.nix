{
  flake,
  config,
  pkgs,
  home-manager,
  ...
}: let
  st-fork = with pkgs; (st.overrideAttrs (oldAttrs: rec {
    src = /. + config.home.homeDirectory + "/flake/home/st";
    buildInputs = oldAttrs.buildInputs ++ [harfbuzz];
  }));

  dwm-fork = with pkgs; (dwm.overrideAttrs (oldAttrs: rec {
    src = /. + config.home.homeDirectory + "/flake/home/dwm";
  }));

  dwmblocks-fork = with pkgs; (stdenv.mkDerivation rec {
    pname = "dwmblocks";
    version = "1.0";
    src = /. + config.home.homeDirectory + "/flake/home/dwmblocks";
    buildInputs = [xorg.libX11];
    installPhase = ''
      install -m755 -D dwmblocks $out/bin/dwmblocks
    '';
  });

  dwm-xsession = {
    enable = true;
    initExtra = ''
      ${pkgs.xorg.xmodmap}/bin/xmodmap -e "remove mod1 = Alt_R"
      ${pkgs.xorg.xmodmap}/bin/xmodmap -e "add mod3 = Alt_R"
      wal -R
      dwm
      dwmblocks &
    '';
  };

  spectrwm-xsession = {
    enable = true;
    initExtra = ''
      wal -R &
      ${pkgs.xorg.xmodmap}/bin/xmodmap -e "remove mod1 = Alt_R"
      ${pkgs.xorg.xmodmap}/bin/xmodmap -e "add mod3 = Alt_R"
    '';
    windowManager.spectrwm = {
      enable = true;
      programs = {
        term = "st";
        search = "dmenu -ip -p 'Window name/id:'";
        browser = "firefox";
        lock = "slock";
        editor = "bash -c 'kakup'";
        projecteditor = "bash -c 'kakup .'";
      };
      bindings = {
        lock = "Mod+s";
        browser = "Mod+w";
        term = "Mod+Return";
        restart = "Mod+Shift+r";
        quit = "Mod+Shift+q";
        editor = "Mod+e";
        projecteditor = "Mod+Shift+e";
      };
      settings = {
        modkey = "Mod4";
        workspace_limit = 5;
        focus_mode = "manual";
        focus_close = "next";
        bar_action = "spectrwmbar";
        bar_action_expand = 1;
        bar_font_color = "grey, white,  rgb:00/00/ff,  rgb:ee/82/ee,  rgb:4b/00/82,  rgb:00/80/00,  rgb:ff/ff/00,  rgb:ff/a5/00, rgb:eb/40/34";
      };
    };
  };
in {
  xsession =
    if true
    then dwm-xsession
    else spectrwm-xsession;
  services.picom = {
    enable = true;
    activeOpacity = 0.9;
    inactiveOpacity = 0.7;
    opacityRules = [
      "100:class_g = 'dwm'"
      "100:name *= 'Firefox'"
      "100:name *= 'LibreWolf'"
    ];
    settings = {
      inactive-opacity-override = false;
      frame-opacity = 1;
    };
  };
  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = 0;
        follow = "keyboard";
        width = 370;
        height = 350;
        offset = "0x19";
        padding = 2;
        horizontal_padding = 2;
        transparency = 25;
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
  home.packages = [
    st-fork
    dwm-fork
    dwmblocks-fork
    pkgs.libnotify
  ];
}
