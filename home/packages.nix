{
  flake,
  config,
  pkgs,
  home-manager,
  username,
  ...
}: {
  home.packages = with pkgs;
    [
      ansible
      kubernetes-helm
      powershell
      azure-cli
      kubectl
      krew
      jq

      htop
      subversion
      ripgrep
      inotify-tools
      fzf
    ]
    ++ (import ../shell-scripts.nix {inherit pkgs config;});
}
