{ lib, modulesPath, ... }: with lib; {
    imports = [
        "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
        ./profiles/core/configuration.nix
        ./profiles/core/hm.nix
        ./profiles/core/git.nix
        ./profiles/core/neovim.nix
    ];
    options = {
        secrets = mkSinkUndeclaredOptions {};
    };
    config = {
        nix.settings = {
            experimental-features = [ "nix-command" "flakes" "ca-derivations" ];
            warn-dirty = false;
        };
        services.getty.autologinUser = mkForce ivi.username;
        hm.xdg.configFile."nvim".source = ./mut/neovim;
    };
}
