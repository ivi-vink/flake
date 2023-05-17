{
  flake,
  config,
  pkgs,
  home-manager,
  ...
}: {
  programs.kakoune = {
    enable = true;
  };
}
