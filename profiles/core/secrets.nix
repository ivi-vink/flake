{inputs,config,lib,pkgs,...}: with lib; {
  imports = [
    inputs.sops-nix.nixosModules.sops
    (mkAliasOptionModule [ "secrets" ] [ "home-manager" "users" "mike" ])
  ];
  sops = {
    gnupg = {
      home = config.hm.programs.gpg.homedir;
      sshKeyPaths = [];
    };
    age.sshKeyPaths = [];

    # Taken from: https://github.com/ncfavier/config/blob/main/modules/secrets.nix
    # GPG running as root can't find my socket dir (https://github.com/NixOS/nixpkgs/issues/57779)
    environment.SOPS_GPG_EXEC = pkgs.writeShellScript "gpg-mike" ''
      exec ${pkgs.util-linux}/bin/runuser -u mike -- ${pkgs.gnupg}/bin/gpg "$@"
    '';

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
    systemPackages = [ pkgs.sops ];
    sessionVariables.SOPS_PGP_FP = "95B594256E6684F46B337254CE5CD59ACAB73E44";
  };

  hm = {
    programs.password-store.enable = true;
  };
}
