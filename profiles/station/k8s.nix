{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
      kubernetes-helm
      kubectl
      kind
  ];
}
