{inputs, config, lib, ...}: with lib; {
  imports = [
    inputs.home-manager.nixosModules.default
    (mkAliasOptionModule [ "hm" ] [ "home-manager" "users" "mike" ])
  ];

  system.extraDependencies = collectFlakeInputs inputs.home-manager;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;
    extraSpecialArgs = { inherit inputs; };
  };

  hm = {
    home.stateVersion = config.system.stateVersion;
    home.enableNixpkgsReleaseCheck = false;

    systemd.user.startServices = "sd-switch";

    manual.html.enable = true;
  };
}
