{machine, inputs,lib,config, ...}: with lib; {
  lib.meta = {
    configPath = if hasAttrByPath ["configPath"] machine then machine.configPath else "/nix-config";
    mkMutableSymlink = path:
      config.hm.lib.file.mkOutOfStoreSymlink
        (config.lib.meta.configPath + removePrefix (toString inputs.self) (toString path));
  };
}
