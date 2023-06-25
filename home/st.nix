{
  flake,
  config,
  pkgs,
  home-manager,
  ...
}: let
  st-fork = with pkgs; (st.overrideAttrs (oldAttrs: rec {
    src = fetchFromGitHub {
      owner = "mvinkio";
      repo = "st";
      rev = "e03a7d3f0b6bf4028389a82d372d0f89a922b9da";
      sha256 = "sha256-xAMChf8DepEnIhb0/GluvcWWBm9d0Pgipm9HeRi1wUk=";
    };
    buildInputs = oldAttrs.buildInputs ++ [harfbuzz];
  }));

  dwm-fork = with pkgs; (st.overrideAttrs (oldAttrs: rec {
    src = ./dwm;
  }));

  dwm-xsession = {
    enable = true;
    initExtra = ''
        ${dwm-fork}
        wal -R &
        ${pkgs.xorg.xmodmap}/bin/xmodmap -e "remove mod1 = Alt_R"
        ${pkgs.xorg.xmodmap}/bin/xmodmap -e "add mod3 = Alt_R"
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
  xsession = if (true) then dwm-xsession else spectrwm-xsession;
  home.packages = [
    st-fork
  ];
}
