{ inputs, config, lib, pkgs, ... }:

{
    imports = [
        inputs.nixos-wsl.nixosModules.default
    ];

    wsl.enable = true;
    wsl.defaultUser = "mike";
    system.stateVersion = "23.05";
    virtualisation.docker.enable = true;
}
