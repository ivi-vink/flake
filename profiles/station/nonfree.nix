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
        "steam"
        "steam-original"
        "steam-run"
        ];

    programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
    };
    hardware.opengl.driSupport32Bit = true;
}
