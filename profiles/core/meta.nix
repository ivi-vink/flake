{inputs,lib,config, ...}: with lib; {
  lib.meta = {
    configPath = "${config.users.users.mike.home}/flake";
    mkMutableSymlink = path:
      config.hm.lib.file.mkOutOfStoreSymlink
        (config.lib.meta.configPath + removePrefix (toString inputs.self) (toString path));
  };
}
