{
  config,
  pkgs,
  ...
}: {
  users.users.mike = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "docker" "transmission"];
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
