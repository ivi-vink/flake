{
  pkgs,
  ...
}: {
  hm = {
    home.packages = with pkgs; [
      k9s
      # krew
      # dasel
      # # initool
      # python311Packages.editorconfig
      # gcc
      # # pkgsi686Linux.glibc
      # gnumake
      # raylib
      # # gdb
      # maim
      # calcurse
      # profanity
      # file
      # ueberzug
      # mypaint
      # lynx
      # pstree
      # pywal
      # bashInteractive
      # k9s
      # powershell
      # azure-cli
      # inotify-tools
      # alejandra
      # statix
      # github-cli
      # lazygit
      # argocd
      # bc
      # # sxiv
      # nushell
      # # sent
      # (nerdfonts.override {fonts = ["FiraCode"];})
      # noto-fonts
      # noto-fonts-emoji
      # # dmenu
      # # librewolf
      # # firefox-wayland
      # # libreoffice
      # # xclip
    ];
  };
}
