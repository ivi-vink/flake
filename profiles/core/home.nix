{
  machine,
  lib,
  config,
  pkgs,
  ...
}: with lib; {
  hm = {
    fonts.fontconfig.enable = true;
    # https://github.com/nix-community/home-manager/issues/4692
    # home.file.".local/bin".source = config.lib.meta.mkMutableSymlink /mut/bin;
    xdg = {
      enable = true;
      mime.enable = !machine.isDarwin;
      mimeApps = optionalAttrs (!machine.isDarwin) {
        enable = true;
        defaultApplications = {
          "text/x-shellscript"        =  ["text.desktop"];
          "application/x-bittorrent"  =  ["torrent.desktop"];
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
          "application/x-ica"         =  ["wfica.desktop"];
          "x-scheme-handler/magnet"   =  ["torrent.desktop"];
          "x-scheme-handler/mailto"   =  ["mail.desktop"];
          "x-scheme-handler/msteams"  =  ["teams.desktop"];
        };
      };
      desktopEntries = with pkgs; optionalAttrs (!machine.isDarwin) {
        text = { type = "Application"; name = "Text editor"; exec = "${st}/bin/st -e kak %u"; };
        file = { type = "Application"; name = "File Manager"; exec = "${st}/bin/st -e lfub %u"; };
        torrent = { type = "Application"; name = "Torrent"; exec = "${coreutils}/bin/env transadd %U"; };
        img = { type = "Application"; name = "Image Viewer"; exec = "${sxiv}/bin/sxiv -a %u"; };
        video = { type = "Application"; name = "Video Viewer"; exec = "${mpv}/bin/mpv -quiet %f"; };
        mail = { type = "Application"; name = "Mail"; exec = "${st}/bin/st -e neomutt %u"; };
        pdf = { type = "Application"; name = "PDF reader"; exec = "${zathura}/bin/zathura %u"; };
        rss = { type = "Application"; name = "RSS feed addition"; exec = "${coreutils}/bin/env rssadd %u"; };
      };
    };

    programs.ssh = {
      enable = true;
      matchBlocks = {
        "*" = {
          identityFile = "${config.ivi.home}/.ssh/id_ed25519_sk";
        };
      };
    };

    home.sessionVariables = {
      EDITOR = "nvim";
      TERMINAL = "st";
    };

    home.sessionPath = [
      "${config.ivi.home}/.krew/bin"
      "${config.ivi.home}/.cargo/bin"
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
      set -g status off
      set -s set-clipboard on
      setw -g mouse on
      set -g default-terminal "st-256color"
      set -ga terminal-overrides ",xterm-256color:Tc"
      set-option -g focus-events on
      set-option -sg escape-time 10
      unbind M-x
      set -g prefix M-x
      bind M-x send-prefix

      set-window-option -g mode-keys vi
      bind-key -T copy-mode-vi v send -X begin-selection
      bind-key -T copy-mode-vi V send -X select-line
      bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel 'xclip -in -selection clipboard'
      bind-key -T copy-mode-vi : command-prompt
    '';
    };

    programs.bash = {
      enable = true;
      bashrcExtra = ''
      ( command -v brew ) &>/dev/null && eval "$(/opt/homebrew/bin/brew shellenv)"
      ( command -v docker ) &>/dev/null && eval "$(docker completion bash)"
      ( command -v kubectl ) &>/dev/null && eval "$(kubectl completion bash)"
      ( command -v zoxide ) &>/dev/null && eval "$(zoxide init bash)"
      export PATH=$PATH:$HOME/.local/bin
      [[ -f ~/.cache/wal/sequences ]] && (cat ~/.cache/wal/sequences &)
      unset LD_PRELOAD
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
      # include nix.sh if it exists
      [[ -f ~/.nix-profile/etc/profile.d/nix.sh ]] && . ~/.nix-profile/etc/profile.d/nix.sh
      export COLORTERM=truecolor
      export GPG_TTY="$(tty)"
      gpgconf --launch gpg-agent

      if [ ! -S ~/.ssh/ssh_auth_sock ]; then
        eval `ssh-agent`
        ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
      fi
      export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
      ssh-add -l > /dev/null || ssh-add ~/.ssh/id_ed25519_sk
    '';
      shellAliases = {
        k9s           = "k9s ";
        k             = "kubectl ";
        d             = "docker ";
        ls            = "ls --color=auto";
        s             = "${if machine.isDarwin then "darwin-rebuild" else "sudo nixos-rebuild"} switch --flake ${config.ivi.home}/flake#${config.networking.hostName}";
        b             = "/run/current-system/bin/switch-to-configuration boot";
        v             = "nvim";
        M             = "xrandr --output HDMI1 --auto --output eDP1 --off";
        m             = "xrandr --output eDP1 --auto --output HDMI1 --off";
        mM            = "xrandr --output eDP1 --auto --output HDMI1 --off";
        newflake      = "nix flake new -t ~/flake ";
        ansible-flake = "nix flake new -t ~/flake#ansible ";
        go-flake      = "nix flake new -t ~/flake#go ";
        lock-pass     = "gpgconf --kill gpg-agent";
      };
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
      enable = !machine.isDarwin;
      enableSshSupport = false;
      defaultCacheTtl = 34550000;
      maxCacheTtl = 34550000;
      pinentryFlavor = "gtk2";
    };
  };
}
