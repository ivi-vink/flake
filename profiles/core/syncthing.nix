{config, lib,...}: with lib; {
  services.syncthing = {
    enable = true;
    user = ivi.username;
    inherit (config.ivi) group;
    dataDir = config.ivi.home;
    overrideDevices = true;
    overrideFolders = true;

    key = config.secrets.syncthing.path;

    settings = let
      allDevices = (filterAttrs (_: m: m.syncthing.id != "") ivi.machines);
    in {
      gui = {
        theme = "default";
        insecureAdminAccess = true;
      };

      devices = mapAttrs (_: m: {
        inherit (m.syncthing) id;
        introducer = m.isServer;
      }) allDevices;

      folders = let
        trashcan = {
          type = "trashcan";
          params.cleanoutDays = "0";
        };
        simple = {
          type = "simple";
          params = {
            keep = "5";
            cleanoutDays = "0";
          };
        };
        allNames = attrNames allDevices;
      in {
        my = {
          path = "${config.ivi.home}/sync/my";
          devices = allNames;
          versioning = simple;
        };
        pictures = {
          path = "${config.ivi.home}/sync/pictures";
          devices = allNames;
          versioning = trashcan;
        };
      };
    };
  };
  environment.systemPackages = [config.services.syncthing.package];
}
