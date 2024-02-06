{inputs, config, lib, ...}: with lib; {
  imports = [
    inputs.home-manager.darwinModules.default
    (mkAliasOptionModule [ "hm" ] [ "home-manager" "users" ivi.username ])
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;
    extraSpecialArgs = { inherit inputs; };
  };

  hm = {
    home.stateVersion = "24.05";
    home.enableNixpkgsReleaseCheck = false;

    systemd.user.startServices = "sd-switch";

    manual.html.enable = true;
  };
}
