{
  config,
  pkgs,
  lib,
  ...
}: with lib; {
  imports = [ (mkAliasOptionModule [ "ivi" ] [ "users" "users" ivi.username ]) ];

  services = {
    resolved.fallbackDns = [
      "1.1.1.1#one.one.one.one"
      "1.0.0.1#one.one.one.one"
      "2606:4700:4700::1111#one.one.one.one"
      "2606:4700:4700::1001#one.one.one.one"
    ];
  };
  security = {
    sudo = {
      wheelNeedsPassword = false;
      extraConfig = ''
        Defaults env_keep+="EDITOR"
        Defaults env_keep+="SSH_CONNECTION SSH_CLIENT SSH_TTY"
        Defaults env_keep+="http_proxy https_proxy"
      '';
    };
  };

  time.timeZone = "Europe/Amsterdam";
  users.users = {
      ${ivi.username} = {
        uid = 1000;
        description = ivi.realName;
        openssh.authorizedKeys.keys = ivi.sshKeys;
        extraGroups = ["wheel" "networkmanager" "docker" "transmission"];
        isNormalUser = true;
      };
      root = {
        openssh.authorizedKeys.keys = config.ivi.openssh.authorizedKeys.keys;
      };
  };

  environment.systemPackages = with pkgs; [
    man-pages
    man-pages-posix
    vim
    wget
    git
    subversion
    htop
    jq
    yq-go
    curl
    fd
    lf
    ripgrep
    parallel
    pinentry-curses
    gnused
    gnutls
    zoxide
    binwalk
    unzip
    gcc
    gnumake
    file
    pstree
    bc
  ] ++ optionals (!pkgs.stdenv.isDarwin) [
    pkgsi686Linux.glibc
    gdb
    pciutils
    dnsutils
    iputils
    inetutils
    usbutils
  ];

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
}
