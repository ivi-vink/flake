{
  inputs,
  config,
  pkgs,
  ...
}: {
  programs.mbsync = {
      enable = true;
  };
  systemd.user.timers.mailsync = {
      Unit = {
          Description = "daemon that syncs mail";
      };
      Timer = {
          OnBootSec = "5m";
          OnUnitActiveSec = "5m";
          Unit = "mailsync.service";
      };
      Install = {
          WantedBy = [ "timers.target" ];
      };
  };
  systemd.user.services.mailsync = {
      Unit = {
          Description = "daemon that syncs mail";
      };
      Service = {
          Type = "oneshot";
          RemainAfterExit = "no";
          ExecSearchPath = "${config.home.profileDirectory}/bin:/run/current-system/sw/bin";
          ExecStart = "${pkgs.coreutils}/bin/env mailsync";
      };
  };
}
