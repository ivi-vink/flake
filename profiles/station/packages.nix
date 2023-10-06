{
  flake,
  config,
  pkgs,
  ...
}: let
  core-packages = with pkgs;
    [
      # nixopsnixops
      age
      sops
      # k8s and friends
      kubernetes-helm
      kubectl
      kind
      krew
      jq
      yq-go
      dasel
      initool
      python311Packages.editorconfig
      gnutls
      # other stuff
      coreutils
      dnsutils
      iputils
      inetutils
      usbutils
      gcc
      pkgsi686Linux.glibc
      gnumake
      raylib
      gdb
      maim
      calcurse
      profanity
      file
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
      htop
      subversion
      ripgrep
      gnused
      gnugrep
      curl
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