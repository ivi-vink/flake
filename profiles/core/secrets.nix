{inputs,config,lib,pkgs,...}: with lib; {
  imports = [
    inputs.sops-nix.nixosModules.sops
    (mkAliasOptionModule [ "secrets" ] [ "home-manager" "users" "mike" ]) # TODO: get username(s) from machine config
  ];
  sops = {
    gnupg = {
      sshKeyPaths = [];
    };
    age.sshKeyPaths = [];
    age.keyFile = "${config.hm.xdg.configHome}/sops/age/keys.txt";

    secrets = mapAttrs' (name: _: let
      parts = splitString "." name;
      base = head parts;
      format = if length parts > 1 then elemAt parts 1 else "binary";
    in
       {
           name = base;
           value = {
               sopsFile = "${inputs.self}/secrets/${name}";
               inherit format;
               key = "lemptop"; # TODO: get actual hostname from somewhere
           };
    }) (builtins.readDir "${inputs.self}/secrets"); # keep it out of the store
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
}
