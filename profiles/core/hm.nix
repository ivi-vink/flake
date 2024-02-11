{inputs, config, lib, pkgs, ...}: with lib; {
  imports = [
    (mkAliasOptionModule [ "hm" ] [ "home-manager" "users" ivi.username ])
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;
    extraSpecialArgs = { inherit inputs; };
  };

  hm = {
    home.stateVersion = if pkgs.stdenv.isDarwin then "24.05" else config.system.stateVersion;
    home.enableNixpkgsReleaseCheck = false;

    systemd.user.startServices = "sd-switch";

    manual.html.enable = true;
  };
}
