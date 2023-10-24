{config, pkgs, lib, ...}: {
    hm.home.packages = with pkgs; [
        (discord.override {
          withVencord = true;
        })
        slack
        discord-ptb
        discord-canary
        citrix_workspace
    ];
    nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          # Add additional package names here
          "discord"
          "discord-ptb"
          "discord-canary"
          "slack"
          "citrix-workspace"
        ];
}
