{inputs,lib,config, ...}: with lib; {
  lib.meta = {
    configPath = "${config.my.home}/flake";
    mkMutableSymlink = path:
      config.hm.lib.file.mkOutOfStoreSymlink
        (config.lib.meta.configPath + removePrefix (toString inputs.self) (toString path));
  };
}
