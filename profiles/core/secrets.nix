{machine,inputs,config,lib,pkgs,...}: with lib;
let
  getSecrets = dir:
    mapAttrs' (name: _: let
      parts = splitString "." name;
      base = head parts;
      format = if length parts > 1 then elemAt parts 1 else "binary";
    in nameValuePair base {
      sopsFile = "${dir}/${name}";
      inherit format;
      key = machine.hostname;
    }) (if (filesystem.pathIsDirectory dir) then
         (filterAttrs (n: v: v != "directory") (builtins.readDir dir))
        else
        {});
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    (mkAliasOptionModule [ "secrets" ] [ "sops" "secrets" ]) # TODO: get my username(s) from machine config
  ];
  config = mkIf machine.secrets {
      sops = {
        secrets = attrsets.mergeAttrsList
            [
                (getSecrets "${inputs.self}/secrets")
                (getSecrets "${inputs.self}/secrets/${machine.hostname}")
            ];
      };

      environment = {
        systemPackages = [
          pkgs.sops
          pkgs.age
        ];
      };

      hm = {
        programs.password-store.enable = true;
      };
  };
}
