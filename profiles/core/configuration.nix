{
  config,
  pkgs,
  lib,
  ...
}: with lib; {
  imports = [ (mkAliasOptionModule [ "ivi" ] [ "users" "users" ivi.username ]) ];

  time.timeZone = "Europe/Amsterdam";
  users.users = {
      ${ivi.username} = {
        uid = 1000;
        isNormalUser = true;
        description = ivi.realName;
        extraGroups = ["wheel" "networkmanager" "docker" "transmission"];
        openssh.authorizedKeys.keys = ivi.sshKeys;
      };
      root = {
        passwordFile = secrets.password.path;
        openssh.authorizedKeys.keys = config.ivi.openssh.authorizedKeys.keys;
      };
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
  environment.systemPackages = with pkgs; [
    man-pages
    man-pages-posix
    vim
    wget
    git
    jq
    yq-go
    curl
    pinentry-curses
    gnused
    htop
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
