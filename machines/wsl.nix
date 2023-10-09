{ config, lib, pkgs, ... }:

{
    imports = [
        <nixos-wsl/modules>
    ];

    wsl.enable = true;
    wsl.defaultUser = "mike";
    system.stateVersion = "23.05";
    virtualisation.docker.enable = true;
}
