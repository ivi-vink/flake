{
  flake,
  username,
  email,
  config,
  pkgs,
  ...
}: {
  home.homeDirectory = "/home/${username}";
  home.username = username;
  home.stateVersion = "22.05";

  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.krew/bin"
  ];

  programs.starship.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.bash = {
    enable = true;
    profileExtra = ''
      # include nix.sh if it exists
      [[ -f ~/.nix-profile/etc/profile.d/nix.sh ]] && . ~/.nix-profile/etc/profile.d/nix.sh
      # source some workspace specific stuff
      [[ -f ~/env.sh ]] && . ~/env.sh
    '';
    shellAliases = {
      k9s = "COLORTERM=truecolor k9s";
      ls = "ls --color=auto";
      s = "sudo nixos-rebuild switch --flake ${config.home.homeDirectory}/flake#";
      b = "/run/current-system/bin/switch-to-configuration boot";
      h = "home-manager switch --flake ${config.home.homeDirectory}/flake#mvinkio --impure";
      fa = "azdo-switch-project";
      v = "nvim";
      V = "nvim -S .vimsession.vim";
      M = "xrandr --output HDMI1 --auto --output eDP1 --off";
      m = "xrandr --output eDP1 --auto --output HDMI1 --off";
      mM = "xrandr --output eDP1 --auto --output HDMI1 --off";
      newflake = "nix flake new -t ~/flake ";
      ansible-flake = "nix flake new -t ~/flake#ansible ";
    };
  };

  programs.git = {
    enable = true;
    userName = "Mike Vink";
    userEmail = email;
    ignores = [
      "/.direnv/"
      "/.envrc"
      "/.env"
      "/.vimsession.vim"
    ];
  };

  programs.gpg = {
    enable = true;
  };
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 34560000;
    maxCacheTtl = 34560000;
  };
  programs.password-store = {
    enable = true;
  };

  xsession = {
    enable = true;
    windowManager.spectrwm = {
      enable = true;
      programs = {
        term = "st";
        search = "dmenu -ip -p 'Window name/id:'";
        browser = "firefox";
        lock = "slock";
      };
      bindings = {
        lock = "Mod+s";
        browser = "Mod+w";
        term = "Mod+Return";
        restart = "Mod+Shift+r";
        quit = "Mod+Shift+q";
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
}
