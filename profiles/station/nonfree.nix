{config, pkgs, lib, ...}: {
    hm.home.packages = [
        (pkgs.discord.override {
          withVencord = true;
        })
        pkgs.slack
        pkgs.discord-ptb
        pkgs.discord-canary
    ];
    nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          # Add additional package names here
          "discord"
          "discord-ptb"
          "discord-canary"
          "slack"
        ];
}
