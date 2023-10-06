{inputs,lib,config, ...}: with lib; {
  lib.meta = {
    configPath = "${config.home.homeDirectory}/flake";
    mkMutableSymlink = path:
      config.lib.file.mkOutOfStoreSymlink
        (config.lib.meta.configPath + removePrefix (toString inputs.self) (toString path));
  };
}
