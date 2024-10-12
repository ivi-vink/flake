{
  machine,
  lib,
  config,
  pkgs,
  ...
}: with lib; {
  programs.tmux = {
    enable = true;
    extraConfig = ''
      set-option -g default-shell ${config.my.shell}/bin/zsh
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

      bind -n M-w switch-client -T windows
      bind -T windows c if 'n=`tmux list-panes | grep -c ^`; [ $n -gt 1 ]' {
         kill-pane
      }
      bind -T windows n splitp
      bind -T windows N splitp -h
      bind -T windows h select-pane -L
      bind -T windows j select-pane -D
      bind -T windows k select-pane -U
      bind -T windows l select-pane -R
      bind -T windows _ resize-pane -Z
      bind -T windows = selectl even-vertical

      set-window-option -g mode-keys vi
      bind-key -T copy-mode-vi v send -X begin-selection
      bind-key -T copy-mode-vi V send -X select-line
      bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel 'xclip -in -selection clipboard'
      bind-key -T copy-mode-vi : command-prompt
    '';
  };

  hm = {
    programs.password-store = {
      enable = true;
      settings = {
        PASSWORD_STORE_DIR = config.synced.password-store.path;
      };
    };

    # fonts.fontconfig.enable = true;
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
        text = { type = "Application"; name = "Text editor"; exec = "${st}/bin/st -e nvim %u"; };
        file = { type = "Application"; name = "File Manager"; exec = "${st}/bin/st -e lfub %u"; };
        torrent = { type = "Application"; name = "Torrent"; exec = "${coreutils}/bin/env transadd %U"; };
        img = { type = "Application"; name = "Image Viewer"; exec = "${sxiv}/bin/sxiv -a %u"; };
        video = { type = "Application"; name = "Video Viewer"; exec = "${mpv}/bin/mpv -quiet %f"; };
        mail = { type = "Application"; name = "Mail"; exec = "${st}/bin/st -e neomutt %u"; };
        pdf = { type = "Application"; name = "PDF reader"; exec = "${zathura}/bin/zathura %u"; };
        rss = { type = "Application"; name = "RSS feed addition"; exec = "${coreutils}/bin/env rssadd %u"; };
      };
    };

    # programs.ssh = {
    #   enable = true;
    #   matchBlocks = {
    #     "*" = {
    #       identityFile = "${config.my.home}/.ssh/id_ed25519_sk";
    #     };
    #   };
    # };

    programs.starship = {
      enable = true;
      enableZshIntegration = false;
    };

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
        autosuggestion.enable = true;
        completionInit = ''
          if [ -z "$ZSHRC_IVI" ]; then
            zmodload zsh/complist
            autoload -Uz +X compinit bashcompinit select-word-style
            select-word-style bash
            zstyle ':completion:*' menu select
            _comp_options+=(globdots) # Include hidden files.
            compinit
            bashcompinit
          fi
        '';
        initExtra = ''
          ZSH_AUTOSUGGEST_MANUAL_REBIND=1
          if command -v pnsh-nvim >/dev/null 2>&1 && [ -z "$ZSHRC_IVI" ]; then
            export COLORTERM=truecolor
            export GPG_TTY="$(tty)"
            gpgconf --launch gpg-agent

            if [ ! -S ~/.ssh/ssh_auth_sock ]; then
              eval `ssh-agent`
              ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
            fi
            export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
            ssh-add -l > /dev/null || ssh-add ~/.ssh/id_ed25519_sk

            if [[ $TERM != "dumb" ]]; then
              eval "$(/etc/profiles/per-user/ivi/bin/starship init zsh)"
            fi

            pnsh-nvim true || {
              echo "Pnsh exited badly :("
            }
          fi
          export GNUPGHOME="''${HOME}/.gnupg"
          export LOCALE_ARCHIVE_2_27="/nix/store/l8hm9q8ndlg2rvav47y7549llh6npznf-glibc-locales-2.39-52/lib/locale/locale-archive"
          export PASSWORD_STORE_DIR="''${HOME}/sync/password-store"
          export XDG_CACHE_HOME="''${HOME}/.cache"
          export XDG_CONFIG_HOME="''${HOME}/.config"
          export XDG_DATA_HOME="''${HOME}/.local/share"
          export XDG_STATE_HOME="''${HOME}/.local/state"

          # Use vim keys in tab complete menu:
          export ZLE_REMOVE_SUFFIX_CHARS=$' ,=\t\n;&|/@'
          export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
          bindkey -M menuselect 'h' vi-backward-char
          bindkey -M menuselect 'k' vi-up-line-or-history
          bindkey -M menuselect 'l' vi-forward-char
          bindkey -M menuselect 'j' vi-down-line-or-history
          set -o emacs


          # Use lf to switch directories and bind it to ctrl-o
          lfcd () {
              tmp="$(mktemp -uq)"
              trap 'rm -f $tmp >/dev/null 2>&1 && trap - HUP INT QUIT TERM EXIT' HUP INT QUIT TERM EXIT
              EDITOR=vremote lfub -last-dir-path="$tmp" "$@"
              if [ -f "$tmp" ]; then
                  dir="$(cat "$tmp")"
                  [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
              fi
          }
          bindkey -s '^o' '^ulfcd\n'

          export FZF_DEFAULT_OPTS='-m --bind ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all'

          # Options to fzf command
          export FZF_COMPLETION_OPTS='--border --info=inline'

          # Use fd (https://github.com/sharkdp/fd) for listing path candidates.
          # - The first argument to the function ($1) is the base path to start traversal
          # - See the source code (completion.{bash,zsh}) for the details.
          _fzf_compgen_path() {
            fd --hidden --follow --exclude ".git" . "$1"
          }

          # Use fd to generate the list for directory completion
          _fzf_compgen_dir() {
            fd --type d --hidden --follow --exclude ".git" . "$1"
          }


          fzf-tail () {
            fzf --tail 100000 --tac --no-sort --exact
          }

          fzf-stern () {
            kubectl config set-context --current --namespace "$1" &&
            kubectl stern -n "$1" "$2" --color always 2>&1 |
                fzf --ansi --tail 100000 --tac --no-sort --exact \
                    --bind 'ctrl-o:execute:kubectl logs {1} | nvim -' \
                    --bind 'enter:execute:kubectl exec -it {1} -- bash' \
                    --preview 'echo {}' --preview-window down:20%:wrap \
                    --header '╱ Enter (kubectl exec) ╱ CTRL-O (open log in vim) ╱'
          }

          helmball() {
            tar --extract --verbose --file "$1" &&
              mv --verbose "''${1%-*}" "''${1%.tgz}" &&
              rm --verbose "$1"
          }

          G () { vi +"chdir ''${1:-.}" +G +only ; }

          login_aws() {
            aws configure list-profiles |
              grep -E -v -e default -e '.*_.*' |
              parallel --jobs 4 --quote \
                sh -c 'aws sts get-caller-identity --profile {} 1>&2 || echo {}' |
              xargs -I{} 'aws sso login --profile {}'

            AWS_PROFILE="$(aws configure list-profiles | grep -v default | fzf)"
            [ -z "$AWS_PROFILE" ] &&
              {
                echo Selected empty aws profile!
                exit 1
              }
            export AWS_PROFILE
            if ! error="$(aws sts get-caller-identity --profile "$AWS_PROFILE" 2>&1)"; then
                case "$error" in
                  *'SSO session associated with this profile has expired'*) aws sso login ;;
                  *'Error loading SSO Token'*) aws sso login ;;
                  *) echo "Not sure what to do with error: $error"; echo "trying to sign in"; aws sso login ;;
                esac
            fi
            eval "$(aws configure export-credentials --profile "$AWS_PROFILE" --format env)"
          }

          login_gcp() {
            gcloud config configurations activate "$(gcloud config configurations list --format json | jq '.[] | "\(.name) \(.properties.core.account)"' -r | fzf | awk '{print $1}')"
            projects="$(gcloud projects list --format='value(name,projectId)' 2>/dev/null)" ||
              {
                gcloud auth login
                projects="$(gcloud projects list --format='value(name,projectId)')"
              }
            project="$(printf '%s' "$projects" | fzf | awk '{ print $2 }')"
            gcloud auth application-default set-quota-project "$project"
            gcloud config set project "$project"

            gcloud auth application-default print-access-token >/dev/null 2>&1 ||
              {
                gcloud auth application-default login
              }
          }

          login_azure() {
            missing_tenants="$(
          grep -v \
            -f /dev/fd/3 /dev/fd/4 3<<-EOF 4<<-EOF
          $(az account list --output json | jq -r '.[] | .tenantId')
          EOF
          $(az account tenant list --output json 2>/dev/null | jq -r '.[].tenantId')
          EOF
          )" && {
                    echo "Found tenants that were not logged in! Logging into all of them"
                    printf '%s' "$missing_tenants
          " | xargs -n1 az login --allow-no-subscriptions --tenant
                }
            set -- $(
              {
                  az account list --all 2>/dev/null ||
                    {
                      az login --allow-no-subscriptions && az account list --all
                    }
              } |  jq '.[] | select(.name | test("N/A.*") | not) | "\(.name)\t\(.id)"' -r | fzf
            )

            sub="$2"
            az account set --subscription "''${sub:?}"
            if ! az resource list >/dev/null 2>&1; then
                az login --allow-no-subscriptions --tenant "$(az account show | jq '.tenantId' -r)"
            fi
          }

          log_in () {
            case $1 in
                aws) login_aws ;;
                gcp) login_gcp ;;
                azure) login_azure ;;
                all)
                  login_aws
                  login_gcp
                  login_azure
                  ;;
                *) echo "Don't know how to switch context for: $1" ;;
            esac
          }

          export ZLE_REMOVE_SUFFIX_CHARS=$' ,=\t\n;&|/@'
          export MANPAGER='nvim +Man!'
          export EDITOR="nvim"
          export TERMINAL="st"
          export PATH="''${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

          # Workarounds for completion here...
          command -v zoxide  >/dev/null 2>&1 && eval "$(zoxide init zsh)"
          if [ -z "$ZSHRC_IVI" ]; then
              krew info stern    >/dev/null 2>&1 && eval "$(kubectl stern --completion zsh)"
              command -v brew    >/dev/null 2>&1 && eval "$(/opt/homebrew/bin/brew shellenv)"
              command -v docker  >/dev/null 2>&1 && eval "$(docker completion zsh)"
              command -v kubectl >/dev/null 2>&1 && eval "$(kubectl completion zsh)"
              command -v pioctl  >/dev/null 2>&1 && eval "$(_PIOCTL_COMPLETE=zsh_source pioctl)"
              command -v aws     >/dev/null 2>&1 && source /run/current-system/sw/share/zsh/site-functions/_aws
              command -v az      >/dev/null 2>&1 && {
                source /run/current-system/sw/share/zsh/site-functions/_az
              }
          fi

          [[ -f ~/.cache/wal/sequences ]] && (cat ~/.cache/wal/sequences &)
          unset LD_PRELOAD

          export PATH="$PATH:$HOME/.local/bin:/opt/homebrew/bin:${config.my.home}/.krew/bin:${config.my.home}/.cargo/bin:${pkgs.ncurses}/bin"

          alias g="git "
          alias t="terraform "
          alias c="xclip -f | xclip -sel c -f "
          alias o="xdg-open "
          alias k="kubectl "
          alias d="docker "
          alias l="ls --color=auto"
          alias s="${if machine.isDarwin then "sudo darwin-rebuild switch --flake ~/nix-config" else "sudo nixos-rebuild switch --flake /nix-config"}"
          alias b="/run/current-system/bin/switch-to-configuration boot"
          alias v="vi "
          alias e="vi "
          alias l="lfub"
          alias M="xrandr --output HDMI1 --auto --output eDP1 --off"
          alias m="xrandr --output eDP1 --auto --output HDMI1 --off"
          alias m="xrandr --output eDP1 --auto --output HDMI1 --off"
          alias n="nix flake new -t ~/flake "
          alias use-gpg-ssh="export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)"
          alias use-fido-ssh="export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock"
        '';
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
        export PATH="$PATH:$HOME/.local/bin:/opt/homebrew/bin:${config.my.home}/.krew/bin:${config.my.home}/.cargo/bin:${pkgs.ncurses}/bin"
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
          s             = "${if machine.isDarwin then "darwin-rebuild" else "sudo nixos-rebuild"} switch --flake ${config.my.home}/flake#${config.networking.hostName}";
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
      pinentryPackage = pkgs.pinentry-gtk2;
      # pinentryFlavor = "gtk2";
    };
  };
}
