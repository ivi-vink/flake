{
  flake,
  config,
  pkgs,
  ...
}: let
  core-packages = with pkgs;
    [
      kubernetes-helm
      kubectl
      kind
      krew
      dasel
      initool
      python311Packages.editorconfig
      gnutls
      gcc
      pkgsi686Linux.glibc
      gnumake
      raylib
      gdb
      maim
      calcurse
      profanity
      file
      jq
      yq-go
      lf
      ueberzug
      mypaint
      lynx
      pstree
      pywal
      bashInteractive
      k9s
      powershell
      azure-cli
      subversion
      ripgrep
      inotify-tools
      alejandra
      statix
      fzf
      github-cli
      lazygit
      fd
      argocd
      parallel
      bc
      sxiv
      nushell
      sent
    ];
  mike-extra-packages = with pkgs; [
    (nerdfonts.override {fonts = ["FiraCode"];})
    noto-fonts
    noto-fonts-emoji
    docker
    k9s
    dmenu
    librewolf
    firefox-wayland
    xclip
    libreoffice
  ];
in {
  hm = {
    home.packages =
      core-packages
      ++
      mike-extra-packages;
  };
}
