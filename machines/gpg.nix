self: { lib, modulesPath, ... }: with lib; {
  imports = [
    "${modulesPath}/profiles/all-hardware.nix"
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    (
      {
        lib,
        pkgs,
        config,
        ...
      }: let
        gpgAgentConf = pkgs.runCommand "gpg-agent.conf" {} ''
          cat <<'CONFIG' > $out
          # https://github.com/drduh/config/blob/master/gpg-agent.conf
          # https://www.gnupg.org/documentation/manuals/gnupg/Agent-Options.html
          pinentry-program /usr/bin/pinentry-curses
          enable-ssh-support
          ttyname $GPG_TTY
          default-cache-ttl 60
          max-cache-ttl 120
          CONFIG
        '';
        gpgConf = pkgs.runCommand "gpg.conf" {} ''
          cat <<'CONFIG' > $out
          # https://github.com/drduh/config/blob/master/gpg.conf
          # https://www.gnupg.org/documentation/manuals/gnupg/GPG-Options.html
          # 'gpg --version' to get capabilities
          # Use AES256, 192, or 128 as cipher
          personal-cipher-preferences AES256 AES192 AES
          # Use SHA512, 384, or 256 as digest
          personal-digest-preferences SHA512 SHA384 SHA256
          # Use ZLIB, BZIP2, ZIP, or no compression
          personal-compress-preferences ZLIB BZIP2 ZIP Uncompressed
          # Default preferences for new keys
          default-preference-list SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed
          # SHA512 as digest to sign keys
          cert-digest-algo SHA512
          # SHA512 as digest for symmetric ops
          s2k-digest-algo SHA512
          # AES256 as cipher for symmetric ops
          s2k-cipher-algo AES256
          # UTF-8 support for compatibility
          charset utf-8
          # No comments in messages
          no-comments
          # No version in output
          no-emit-version
          # Disable banner
          no-greeting
          # Long key id format
          keyid-format 0xlong
          # Display UID validity
          list-options show-uid-validity
          verify-options show-uid-validity
          # Display all keys and their fingerprints
          with-fingerprint
          # Display key origins and updates
          #with-key-origin
          # Cross-certify subkeys are present and valid
          require-cross-certification
          # Disable caching of passphrase for symmetrical ops
          no-symkey-cache
          # Output ASCII instead of binary
          armor
          # Enable smartcard
          use-agent
          # Disable recipient key ID in messages (breaks Mailvelope)
          throw-keyids
          # Default key ID to use (helpful with throw-keyids)
          #default-key 0xFF00000000000001
          #trusted-key 0xFF00000000000001
          # Group recipient keys (preferred ID last)
          #group keygroup = 0xFF00000000000003 0xFF00000000000002 0xFF00000000000001
          # Keyserver URL
          #keyserver hkps://keys.openpgp.org
          #keyserver hkps://keys.mailvelope.com
          #keyserver hkps://keyserver.ubuntu.com:443
          #keyserver hkps://pgpkeys.eu
          #keyserver hkps://pgp.circl.lu
          #keyserver hkp://zkaan2xfbuxia2wpf7ofnkbz6r5zdbbvxbunvp5g2iebopbfc4iqmbad.onion
          # Keyserver proxy
          #keyserver-options http-proxy=http://127.0.0.1:8118
          #keyserver-options http-proxy=socks5-hostname://127.0.0.1:9050
          # Enable key retrieval using WKD and DANE
          #auto-key-locate wkd,dane,local
          #auto-key-retrieve
          # Trust delegation mechanism
          #trust-model tofu+pgp
          # Show expired subkeys
          #list-options show-unusable-subkeys
          # Verbose output
          #verbose
          CONFIG
        '';

        dicewareAddress = "localhost";
        dicewarePort = 8080;
        viewYubikeyGuide = pkgs.writeShellScriptBin "view-yubikey-guide" ''
          viewer="${pkgs.glow}/bin/glow -p"
          exec $viewer "${self}/README.md"
        '';
        yubikeyGuide = pkgs.symlinkJoin {
          name = "yubikey-guide";
          paths = [viewYubikeyGuide];
        };
        dicewareScript = pkgs.writeShellScriptBin "diceware-webapp" ''
          viewer="$(type -P xdg-open || true)"
          if [ -z "$viewer" ]; then
            viewer="chromium"
          fi
          exec $viewer "http://"${lib.escapeShellArg dicewareAddress}":${toString dicewarePort}/index.html"
        '';
        dicewarePage = pkgs.stdenv.mkDerivation {
          name = "diceware-page";
          src = pkgs.fetchFromGitHub {
            owner = "grempe";
            repo = "diceware";
            rev = "9ef886a2a9699f73ae414e35755fd2edd69983c8";
            sha256 = "44rpK8svPoKx/e/5aj0DpEfDbKuNjroKT4XUBpiOw2g=";
          };
          patches = [
            # Include changes published on https://secure.research.vt.edu/diceware/
            (self + /diceware-vt.patch)
          ];
          buildPhase = ''
            cp -a . $out
          '';
        };
      in {
        isoImage = {
          isoName = mkForce "yubikeyLive.iso";
          # As of writing, zstd-based iso is 1542M, takes ~2mins to
          # compress. If you prefer a smaller image and are happy to
          # wait, delete the line below, it will default to a
          # slower-but-smaller xz (1375M in 8mins as of writing).
          squashfsCompression = "zstd";

          appendToMenuLabel = " YubiKey Live ${self.lastModifiedDate}";
          makeEfiBootable = true; # EFI booting
          makeUsbBootable = true; # USB booting
        };

        swapDevices = [];

        boot = {
          tmp.cleanOnBoot = true;
          kernel.sysctl = {"kernel.unprivileged_bpf_disabled" = 1;};
        };

        services = {
          pcscd.enable = true;
          udev.packages = [pkgs.yubikey-personalization];
          # Automatically log in at the virtual consoles.
          getty.autologinUser = mkForce my.username;
          displayManager = {
            autoLogin = {
              enable = true;
              user = my.username;
            };
          };
          # Host the `https://secure.research.vt.edu/diceware/` website offline
          nginx = {
            enable = true;
            virtualHosts."diceware.local" = {
              listen = [
                { addr = dicewareAddress; port = dicewarePort; }
              ];
              root = "${dicewarePage}";
            };
          };
        };

        programs = {
          ssh.startAgent = false;
          gnupg = {
            dirmngr.enable = true;
            agent = {
              enable = true;
              enableSSHSupport = true;
            };
          };
        };

        security = {
          pam.services.lightdm.text = ''
            auth sufficient pam_succeed_if.so user ingroup wheel
          '';
          sudo = {
            enable = true;
            wheelNeedsPassword = false;
          };
        };

        environment.systemPackages = with pkgs; [
          # Tools for backing up keys
          paperkey
          pgpdump
          parted
          cryptsetup

          # Yubico's official tools
          yubikey-manager
          yubikey-manager-qt
          yubikey-personalization
          yubikey-personalization-gui
          yubico-piv-tool
          yubioath-flutter

          # Testing
          ent

          # Password generation tools
          diceware
          pwgen
          rng-tools

          # Might be useful beyond the scope of the guide
          cfssl
          pcsctools
          tmux
          htop

          # This guide itself (run `view-yubikey-guide` on the terminal
          # to open it in a non-graphical environment).
          yubikeyGuide
          dicewareScript

          # PDF and Markdown viewer
          zathura
          glow
        ];

        # Disable networking so the system is air-gapped
        # Comment all of these lines out if you'll need internet access
        boot.initrd.network.enable = false;
        networking = {
          resolvconf.enable = false;
          dhcpcd.enable = false;
          dhcpcd.allowInterfaces = [];
          interfaces = {};
          firewall.enable = true;
          useDHCP = false;
          useNetworkd = false;
          wireless.enable = false;
          networkmanager.enable = lib.mkForce false;
        };

        # Unset history so it's never stored Set GNUPGHOME to an
        # ephemeral location and configure GPG with the guide

        environment.interactiveShellInit = ''
          unset HISTFILE
          export GNUPGHOME="/run/user/$(id -u)/gnupg"
          if [ ! -d "$GNUPGHOME" ]; then
            echo "Creating \$GNUPGHOME…"
            install --verbose -m=0700 --directory="$GNUPGHOME"
          fi
          [ ! -f "$GNUPGHOME/gpg.conf" ] && cp --verbose "${gpgConf}" "$GNUPGHOME/gpg.conf"
          [ ! -f "$GNUPGHOME/gpg-agent.conf" ] && cp --verbose ${gpgAgentConf} "$GNUPGHOME/gpg-agent.conf"
          echo "\$GNUPGHOME is \"$GNUPGHOME\""
        '';

        hm.xsession.initExtra = ''
          ${pkgs.xorg.xset}/bin/xset r rate 230 30
          [ -z "$(lsusb | grep microdox)" ] && ${pkgs.xorg.setxkbmap}/bin/setxkbmap -option "ctrl:swapcaps"
          dwm
        '';

        # Copy the contents of contrib to the home directory, add a
        # shortcut to the guide on the desktop, and link to the whole
        # repo in the documents folder.
        system.activationScripts.yubikeyGuide = let
          homeDir = "/home/${my.username}/";
          desktopDir = homeDir + "Desktop/";
          documentsDir = homeDir + "Documents/";
        in ''
          mkdir -p ${desktopDir} ${documentsDir}
          chown ${my.username} ${homeDir} ${desktopDir} ${documentsDir}

          cp -R ${self}/contrib/* ${homeDir}
          ln -sfT ${self} ${documentsDir}/YubiKey-Guide
        '';
        system.stateVersion = "24.05";
      }
    )
  ];
}
