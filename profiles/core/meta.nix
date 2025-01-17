{inputs,lib,config, ...}: with lib; {
  lib.meta = {
    configPath = "${config.my.home}/nix-config";
    mkMutableSymlink = path:
      config.hm.lib.file.mkOutOfStoreSymlink
        (config.lib.meta.configPath + removePrefix (toString inputs.self) (toString path));
  };
}
