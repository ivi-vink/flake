{
  pkgs,
  lib,
  ...
}: with lib; {
  hm = {
    home.packages = with pkgs; [
      (nerdfonts.override {fonts = ["FiraCode"];})
      noto-fonts
      noto-fonts-emoji
      k9s
      krew
      dasel
      python311Packages.editorconfig
      gcc
      gnumake
      calcurse
      file
      ueberzug
      pstree
      pywal
      bashInteractive
      powershell
      azure-cli
      alejandra
      statix
      github-cli
      lazygit
      argocd
      bc
      nushell
    ] ++ optionals (!pkgs.stdenv.isDarwin) [
      inotify-tools
      raylib
      maim
      profanity
      mypaint
      lynx
      sxiv
      sent
      initool
      pkgsi686Linux.glibc
      gdb
      dmenu
      librewolf
      firefox-wayland
      libreoffice
      xclip
    ];
  };
}
