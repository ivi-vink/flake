{ config, lib, pkgs, ... }: with lib; {
  environment.systemPackages = with pkgs; [khard];
  hm = {
    xdg.configFile."khard/khard.conf".text = ''
      [addressbooks]
      [[mike]]
      path = ${config.hm.accounts.contact.accounts.mike.local.path}/contacts

      [general]
      default_action=list
    '';
    services.vdirsyncer.enable = true;
    programs = {
      vdirsyncer.enable = true;
      khal.enable = true;
    };
    accounts.calendar.basePath = "Cal";
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
          url = "https://cal.${my.domain}";
          userName = "mike";
          passwordCommand = ["${pkgs.bashInteractive}/bin/bash" "-c" "echo 'hi'"];
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
    accounts.contact.basePath = "Cal";
    accounts.contact.accounts = {
      mike = {
        local = {
          type = "filesystem";
          fileExt = ".vcf";
        };
        remote = {
          type = "carddav";
          url = "https://cal.${my.domain}";
          userName = "mike";
          passwordCommand = ["${pkgs.bashInteractive}/bin/bash" "-c" "echo 'hi'"];
        };
        vdirsyncer = {
          enable = true;
          collections = ["contacts"];
          conflictResolution = "remote wins";
        };
      };
    };
  };
}
