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
      krew
      jq
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
    ]
    ++ (import ../shell-scripts.nix {inherit pkgs config;});
  mike-extra-packages = with pkgs; [
    (nerdfonts.override {fonts = ["FiraCode"];})
    docker
    k9s
    dmenu
    firefox-wayland
    xclip
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
