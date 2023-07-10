{
  flake,
  username,
  email,
  config,
  pkgs,
  ...
}: {
  programs.home-manager.enable = true;
  home.homeDirectory = "/home/${username}";
  home.username = username;
  home.stateVersion = "23.05";
  fonts.fontconfig.enable = true;
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
    mime.enable = true;
    desktopEntries = {
        text= { type = "Application"; name = "Text editor"; exec = "${pkgs.st}/bin/st -e kak %u"; };
        file = { type = "Application"; name = "File Manager"; exec = "${pkgs.st}/bin/st -e lfub %u"; };
        torrent = { type = "Application"; name = "Torrent"; exec = "${pkgs.coreutils}/bin/env transadd %U"; };
        img = { type = "Application"; name = "Image Viewer"; exec = "${pkgs.sxiv}/bin/sxiv -a %u"; };
        video = { type = "Application"; name = "Video Viewer"; exec = "${pkgs.mpv}/bin/mpv -quiet %f"; };
        mail = { type = "Application"; name = "Mail"; exec = "${pkgs.st}/bin/st -e neomutt %u"; };
        pdf = { type = "Application"; name = "PDF reader"; exec = "${pkgs.zathura}/bin/zathura %u"; };
        rss = { type = "Application"; name = "RSS feed addition"; exec = "${pkgs.coreutils}/bin/env rssadd %u"; };
    };
  };

  programs.ssh = {
      enable = true;
      matchBlocks = {
          "*" = {
              identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
          };
      };
  };

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
      # unbind C-b
      # set -g prefix C-space
      # bind C-space send-prefix

      bind-key R source ${config.xdg.configHome}/tmux/tmux.conf; display-message "sourced ${config.xdg.configHome}/tmux/tmux.conf!"

      set-window-option -g mode-keys vi
      bind-key -T copy-mode-vi v send -X begin-selection
      bind-key -T copy-mode-vi V send -X select-line
      bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel 'xclip -in -selection clipboard'
      bind-key -T copy-mode-vi : command-prompt

      bind-key -T window k select-pane -t '{up-of}'
      bind-key -T window j select-pane -t '{down-of}'
      bind-key -T window l select-pane -t '{right-of}'
      bind-key -T window h select-pane -t '{left-of}'
      bind-key -T window = select-layout even-vertical
      bind-key -T window o kill-pane -a
      bind-key -T window n run-shell '
        window="$(tmux display -p "#{window_name}")"
        if [[ "''${window##kakc@}" != "$window" ]]; then
            tmux splitw "kak -c ''${window##kakc@}"
        else
            tmux splitw "kak -c ''${KAK_SERVER##kaks@}"
        fi
      '
      bind -n C-space switch-client -T window

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
      export GPG_TTY="$(tty)"
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      gpgconf --launch gpg-agent
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
      h             = "home-manager switch --flake ${config.home.homeDirectory}/flake --impure";
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

    # https://github.com/drduh/config/blob/master/gpg.conf
    # https://www.gnupg.org/documentation/manuals/gnupg/GPG-Configuration-Options.html
    # https://www.gnupg.org/documentation/manuals/gnupg/GPG-Esoteric-Options.html
  programs.gpg = {
    enable = true;
    scdaemonSettings = {
        disable-ccid = true;
    };
    settings = {
        personal-cipher-preferences = "AES256 AES192 AES";
        personal-digest-preferences = "SHA512 SHA384 SHA256";
        personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
        default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
        cert-digest-algo = "SHA512";
        s2k-digest-algo = "SHA512";
        s2k-cipher-algo = "AES256";
        charset = "utf-8";
        fixed-list-mode = true;
        no-comments = true;
        no-emit-version = true;
        no-greeting = true;
        keyid-format = "0xlong";
        list-options = "show-uid-validity";
        verify-options = "show-uid-validity";
        "with-fingerprint" = true;
        require-cross-certification = true;
        no-symkey-cache = true;
        use-agent = true;
        throw-keyids = true;
    };
  };
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 34550000;
    maxCacheTtl = 34550000;
  };
  programs.password-store = {
    enable = true;
  };
}
