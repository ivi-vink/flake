{lib,...}: with lib; {
  services.syncthing = {
    enable = true;
    user = ivi.username;
    inherit (config.ivi) group;
    overrideDevices = true;
    overrideFolders = true;

    devices = mapAttrs (_: m: {
      inherit (m.syncthing) id;
      introducer = m.isServer;
    }) (filterAttrs (_: m: m.syncthing.enable) ivi.machines);
  };
}
