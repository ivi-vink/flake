{
  machine,
  config,
  pkgs,
  lib,
  ...
}:

with lib;

{
  environment.systemPackages = with pkgs; [
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
    fzf
    ripgrep
    parallel
    pinentry-curses
    gnused
    gnutls
    zoxide
    binwalk
    unzip
    # gcc
    gnumake
    file
    # psmisc
    bc
    # mediainfo
    bat
    openpomodoro-cli
    coreutils
    killall
  ] ++ (optionals (!machine.isDarwin) [
    nsxiv
    ueberzugpp
    man-pages
    man-pages-posix
    # pkgsi686Linux.glibc
    gdb
    pciutils
    dnsutils
    iputils
    inetutils
    usbutils
  ]);
}
