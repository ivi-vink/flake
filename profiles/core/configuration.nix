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
        home = "/Users/ivi";
        uid = 1000;
        description = ivi.realName;
        openssh.authorizedKeys.keys = ivi.sshKeys;
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
  ];

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
}
