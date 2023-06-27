{
  flake,
  config,
  pkgs,
  home-manager,
  username,
  ...
}: let
  core-packages = with pkgs;
    [
      # k8s and friends
      kubernetes-helm
      kubectl
      kind
      krew
      jq
      yq-go
      dasel
      initool
      nnn
      python311Packages.editorconfig
      # shell tools
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
    ]
    ++ (import ../shell-scripts.nix {inherit pkgs config;});
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
  home.packages =
    core-packages
    ++ (
      if (username == "mike")
      then mike-extra-packages
      else []
    );
}
