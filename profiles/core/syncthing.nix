{machines, machine, config, lib,...}: with lib; let
    group = if machine.isDarwin then (builtins.toString config.my.gid) else config.my.group;
in {
  imports = [
    (mkAliasOptionModule [ "synced" ] [ "services" "syncthing" "settings" "folders" ])
  ];

  services.syncthing = {
    enable = machine.syncthing.enable;
    user = my.username;
    inherit group;
    dataDir = config.my.home;
    overrideDevices = true;
    overrideFolders = true;

    key = config.secrets.syncthing.path;

    settings = let
      allDevices = (filterAttrs (_: m: m.syncthing.id != "") machines);
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
          path = "${config.my.home}/sync/my";
          devices = allNames;
          versioning = simple;
        };
        pictures = {
          path = "${config.my.home}/sync/pictures";
          devices = allNames;
          versioning = trashcan;
        };
        password-store = {
          path = "${config.my.home}/sync/password-store";
          devices = allNames;
          versioning = trashcan;
        };
      };
    };
  };
  environment.systemPackages = [config.services.syncthing.package];
}
