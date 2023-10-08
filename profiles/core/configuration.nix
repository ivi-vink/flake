{
  config,
  pkgs,
  ...
}: {
  users.users.mike = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "docker" "transmission"];
  };

  virtualisation.docker.enable = true;

  hardware.keyboard.qmk.enable = true;
  services.udev.extraRules = ''
    # Yubico Yubikey II
    ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0010|0110|0111|0114|0116|0401|0403|0405|0407|0410", \
        ENV{ID_SECURITY_TOKEN}="1"

    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0200|0402|0403|0406|0407|0410", TAG+="uaccess"
  '';

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "lemptop";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Amsterdam";

  services.xserver.enable = true;
  services.xserver.displayManager.startx.enable = true;
  services.xserver.libinput.enable = true;

  services.udev.packages = [ pkgs.yubikey-personalization ];
  services.pcscd.enable = true;
  security.pam.services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
  };

  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.transmission = {
      enable = true;
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  programs.slock.enable = true;

  documentation.dev.enable = true;
  environment.systemPackages = with pkgs; [
    man-pages
    man-pages-posix
    vim
    wget
    git
    pinentry-curses
  ];

  system.stateVersion = "23.05";
  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
}
