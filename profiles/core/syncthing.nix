{lib,...}: with lib; {
  services.syncthing = {
    enable = true;
    user = ivi.username;
  };
}
