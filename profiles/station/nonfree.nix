{pkgs, lib, ...}: with lib; {
    hm.home.packages = with pkgs; [
        teams
        discord
        slack
    ];
    nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          # Add additional package names here
          "teams-1.6.00.4464"
          "discord"
          "discord-ptb"
          "discord-canary"
          "slack"
          "citrix-workspace"
          "steam"
          "steam-original"
          "steam-run"
        ];

    programs = optionalAttrs (!pkgs.stdenv.isDarwin) {
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
      };
      hardware.opengl.driSupport32Bit = true;
    };
}
