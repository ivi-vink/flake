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
  home.stateVersion = "23.05";

  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.krew/bin"
    "${config.home.homeDirectory}/.cargo/bin"
    "${pkgs.ncurses}/bin"
  ];

  programs.starship.enable = false;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.readline = {
    enable = true;
    extraConfig = ''
      set editing-mode vi
      $if mode=vi

      set keymap vi-command
      # these are for vi-command mode
      Control-l: clear-screen

      set keymap vi-insert
      # these are for vi-insert mode
      Control-l: clear-screen
      $endif
    '';
  };

  programs.tmux = {
    enable = true;
    extraConfig = ''
      set-option -g default-shell ${pkgs.bashInteractive}/bin/bash
      set -s set-clipboard on
      set -g default-terminal "xterm-256color"
      set-option -sa terminal-overrides ",xterm-256color:RGB"
      set-option -g focus-events on
      set-option -sg escape-time 10

      set-window-option -g mode-keys vi
      bind-key -T copy-mode-vi v send -X begin-selection
      bind-key -T copy-mode-vi V send -X select-line
      bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel 'xclip -in -selection clipboard'
      bind-key -T copy-mode-vi : command-prompt

      # Make our own copy-mode with Kakoune!
      #        cursor_y=$(tmux display-message -t "''${pane_id}" -p "#{cursor_y}") ;\
      #        cursor_x=$(tmux display-message -t "''${pane_id}" -p "#{cursor_x}") ;\
      #        pane_height=$(tmux display-message -t "''${pane_id}" -p "#{pane_height}") ;\
      #        line_count="$(wc -l "$file" |awk "{print \$1}")" ;\
      #        sel_line=$(( line_count - ( pane_height - cursor_y ) + 1 )) ;\
      #        printf "sel = %s\n" "$line_count" >>/tmp/debug.log ;\
      #        cursor="''${sel_line}.''${cursor_x},''${sel_line}.''${cursor_x}" ;\
      #        printf "cursor = %s\n" "$cursor" >>/tmp/debug.log

      bind -n C-s run-shell tmux-normal-mode
      bind -n C-q run-shell 'tmux-normal-mode --quit'
    '';
  };

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      unset LD_PRELOAD
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
      # include nix.sh if it exists
      [[ -f ~/.nix-profile/etc/profile.d/nix.sh ]] && . ~/.nix-profile/etc/profile.d/nix.sh
      # source some workspace specific stuff
      [[ -f ~/env.sh ]] && . ~/env.sh
      export COLORTERM=truecolor
    '';
    shellAliases = {
      k9s = "k9s";
      k = "kubectl ";
      d = "docker ";
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
      go-flake = "nix flake new -t ~/flake#go ";
      lock-pass = "gpgconf --kill gpg-agent";
    };
  };

  programs.git = {
    enable = true;
    userName = "Mike Vink";
    userEmail = email;
    extraConfig = {
      worktree.guessRemote = true;
      mergetool.fugitive.cmd = "vim -f -c \"Gdiff\" \"$MERGED\"";
      merge.tool = "fugitive";
    };
    ignores = [
      "/.direnv/"
      "/.envrc"
      "/.env"
      ".vimsession.vim"
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
    initExtra = ''
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
