{ lib, ... }: with lib; {
  hm = {
    accounts.calendar.basePath = "Cal";
    services.vdirsyncer.enable = true;
    programs = {
      vdirsyncer.enable = true;
      khal.enable = true;
    };
    accounts.calendar.accounts = {
      mike = {
        primary = true;
        primaryCollection = "tasks";
        local = {
          type = "filesystem";
          fileExt = ".ics";
        };
        remote = {
          type = "caldav";
          url = "https://cal.${ivi.domain}";
          userName = "mike";
          passwordCommand = ["echo" "''"];
        };
        vdirsyncer = {
          enable = true;
          collections = ["tasks" "pomp"];
          conflictResolution = "remote wins";
        };
        khal = {
          enable = true;
          type = "discover";
          color = "light green";
        };
      };
    };
  };
}
