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
      # shell tools
      powershell
      azure-cli
      htop
      subversion
      ripgrep
      inotify-tools
      fzf
      github-cli
      fd
      argocd
      docker-client
    ]
    ++ (import ../shell-scripts.nix {inherit pkgs config;});
  mike-extra-packages = with pkgs; [
    (nerdfonts.override {fonts = ["FiraCode"];})
    docker
    k9s
    dmenu
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
