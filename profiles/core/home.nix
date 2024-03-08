{
  machine,
  lib,
  config,
  pkgs,
  ...
}: with lib; {
  programs.tmux = let
    config = ''
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
  in {
    enable = true;
  } // (if machine.isDarwin then {
    tmuxConfig = config;
  } else {
    extraConfig = config;
  });

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

    programs = {
      zsh = {
        enable = true;
        completionInit = ''
        autoload -U compinit select-word-style select-word-style
        select-word-style bash
        zstyle ':completion:*' menu select
        zmodload zsh/complist
        compinit
        _comp_options+=(globdots) # Include hidden files.
        '';
        initExtra = ''
          # Use vim keys in tab complete menu:
          bindkey -M menuselect 'h' vi-backward-char
          bindkey -M menuselect 'k' vi-up-line-or-history
          bindkey -M menuselect 'l' vi-forward-char
          bindkey -M menuselect 'j' vi-down-line-or-history


          # Use lf to switch directories and bind it to ctrl-o
          lfcd () {
              tmp="$(mktemp -uq)"
              trap 'rm -f $tmp >/dev/null 2>&1 && trap - HUP INT QUIT TERM EXIT' HUP INT QUIT TERM EXIT
              EDITOR=vremote lf -last-dir-path="$tmp" "$@"
              if [ -f "$tmp" ]; then
                  dir="$(cat "$tmp")"
                  [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
              fi
          }
          bindkey -s '^o' '^ulfcd\n'

          export EDITOR="nvim"
          export TERMINAL="st"
          ( command -v brew ) &>/dev/null && eval "$(/opt/homebrew/bin/brew shellenv)"
          ( command -v docker ) &>/dev/null && eval "$(docker completion zsh)"
          ( command -v kubectl ) &>/dev/null && eval "$(kubectl completion zsh)"
          ( command -v zoxide ) &>/dev/null && eval "$(zoxide init zsh)"
          export PATH="$PATH:$HOME/.local/bin:/opt/homebrew/bin:${config.ivi.home}/.krew/bin:${config.ivi.home}/.cargo/bin:${pkgs.ncurses}/bin"
          [[ -f ~/.cache/wal/sequences ]] && (cat ~/.cache/wal/sequences &)
          unset LD_PRELOAD

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
          v             = "vremote";
          lf            = "lfub";
          M             = "xrandr --output HDMI1 --auto --output eDP1 --off";
          m             = "xrandr --output eDP1 --auto --output HDMI1 --off";
          mM            = "xrandr --output eDP1 --auto --output HDMI1 --off";
          newflake      = "nix flake new -t ~/flake ";
          ansible-flake = "nix flake new -t ~/flake#ansible ";
          go-flake      = "nix flake new -t ~/flake#go ";
          lock-pass     = "gpgconf --kill gpg-agent";
          use-gpg-ssh   = "export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)";
          use-fido-ssh  = "export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock";
        };
      };

      bash = {
        enable = false;
        bashrcExtra = ''
        export EDITOR="nvim"
        export TERMINAL="st"
        ( command -v brew ) &>/dev/null && eval "$(/opt/homebrew/bin/brew shellenv)"
        ( command -v docker ) &>/dev/null && eval "$(docker completion bash)"
        ( command -v kubectl ) &>/dev/null && eval "$(kubectl completion bash)"
        ( command -v zoxide ) &>/dev/null && eval "$(zoxide init bash)"
        export PATH="$PATH:$HOME/.local/bin:/opt/homebrew/bin:${config.ivi.home}/.krew/bin:${config.ivi.home}/.cargo/bin:${pkgs.ncurses}/bin"
        [[ -f ~/.cache/wal/sequences ]] && (cat ~/.cache/wal/sequences &)
        unset LD_PRELOAD
        # include nix.sh if it exists

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
          use-gpg-ssh   = "export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)";
          use-fido-ssh  = "export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock";
        };
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
