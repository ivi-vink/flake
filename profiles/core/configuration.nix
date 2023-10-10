{
  config,
  pkgs,
  ...
}: {
  users.users.mike = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "docker" "transmission"];
  };
  security = {
      sudo = {
        wheelNeedsPassword = false;
        extraConfig = ''
          Defaults env_keep+="EDITOR"
          Defaults env_keep+="SSH_CONNECTION SSH_CLIENT SSH_TTY"
          Defaults env_keep+="http_proxy https_proxy"
        '';
      };
  };
  environment.systemPackages = with pkgs; [
    man-pages
    man-pages-posix
    vim
    wget
    git
    curl
    pinentry-curses
    gnused
    gnugrep
    htop
    dnsutils
    iputils
    inetutils
    usbutils
  ];


  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
}
