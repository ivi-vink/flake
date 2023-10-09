{ inputs, config, lib, pkgs, ... }:

{
    imports = [
        inputs.nixos-wsl.nixosModules.default
    ];

    environment.systemPackages = with pkgs; [
      git
    ];

    wsl = {
        enable = true;
        defaultUser = "mike";
        wslConf.network.generateResolveConf = false;
    };
    system.stateVersion = "23.05";
    virtualisation.docker.enable = true;
}
