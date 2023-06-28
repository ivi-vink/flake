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
  xdg = {
    enable = true;
    mimeApps = {
        enable = true;
        defaultApplications = {
            "text/x-shellscript"        =  ["text.desktop"];
            "x-scheme-handler/magnet"   =  ["torrent.desktop"];
            "application/x-bittorrent"  =  ["torrent.desktop"];
            "x-scheme-handler/mailto"   =  ["mail.desktop"];
            "text/plain"                =  ["text.desktop"];
            "application/postscript"    =  ["pdf.desktop"];
            "application/pdf"           =  ["pdf.desktop"];
            "image/png"                 =  ["img.desktop"];
            "image/jpeg"                =  ["img.desktop"];
            "image/gif"                 =  ["img.desktop"];
            "application/rss+xml"       =  ["rss.desktop"];
            "video/x-matroska"          =  ["video.desktop"];
            "video/mp4"                 =  ["video.desktop"];
            "x-scheme-handler/lbry"     =  ["lbry.desktop"];
            "inode/directory"           =  ["file.desktop"];
        };
    };
    desktopEntries = {
    };
  };

  fonts.fontconfig.enable = true;
  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "kak";
    TERMINAL = "st";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.krew/bin"
    "${config.home.homeDirectory}/.cargo/bin"
    "${pkgs.ncurses}/bin"
  ];

  programs.starship.enable = true;

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
      setw -g mouse on
      set -g default-terminal "xterm-256color"
      set -as terminal-overrides ',xterm*:RGB'
      set-option -g focus-events on
      set-option -sg escape-time 10

      set-window-option -g mode-keys vi
      bind-key -T copy-mode-vi v send -X begin-selection
      bind-key -T copy-mode-vi V send -X select-line
      bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel 'xclip -in -selection clipboard'
      bind-key -T copy-mode-vi : command-prompt

      bind -n C-s run-shell tmux-normal-mode
      bind -n C-q run-shell 'tmux-normal-mode --quit'
    '';
  };

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      [[ -f ~/.cache/wal/sequences ]] && (cat ~/.cache/wal/sequences &)
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
      e             = "kakup ";
      es            = "kakup -f";
      k9s           = "k9s";
      k             = "kubectl ";
      d             = "docker ";
      ls            = "ls --color=auto";
      s             = "sudo nixos-rebuild switch --flake ${config.home.homeDirectory}/flake#";
      b             = "/run/current-system/bin/switch-to-configuration boot";
      h             = "home-manager switch --flake ${config.home.homeDirectory}/flake#mvinkio --impure";
      fa            = "azdo-switch-project";
      v             = "nvim";
      V             = "nvim -S .vimsession.vim";
      M             = "xrandr --output HDMI1 --auto --output eDP1 --off";
      m             = "xrandr --output eDP1 --auto --output HDMI1 --off";
      mM            = "xrandr --output eDP1 --auto --output HDMI1 --off";
      newflake      = "nix flake new -t ~/flake ";
      ansible-flake = "nix flake new -t ~/flake#ansible ";
      go-flake      = "nix flake new -t ~/flake#go ";
      lock-pass     = "gpgconf --kill gpg-agent";
    };
  };

  programs.nushell.enable = true;

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
}
