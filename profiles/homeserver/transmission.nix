{ config, lib, ... }: with lib; {
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  users.groups.multimedia = { };
  users.users.${ivi.username}.extraGroups = [ "multimedia" ];

  systemd.tmpfiles.rules = [
    "d /data 0770 - multimedia - -"
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "plexmediaserver"
      ];

  services.nginx = {
      virtualHosts = {
        "sonarr.${ivi.domain}"  = { locations."/" = { proxyPass = "http://127.0.0.1:8989"; }; };
        "radarr.${ivi.domain}"  = { locations."/" = { proxyPass = "http://127.0.0.1:7878"; }; };
        "bazarr.${ivi.domain}"  = { locations."/" = { proxyPass = "http://127.0.0.1:${toString config.services.bazarr.listenPort}"; }; };
        "readarr.${ivi.domain}"  = { locations."/" = { proxyPass = "http://127.0.0.1:8787"; }; };
        "prowlarr.${ivi.domain}"  = { locations."/" = { proxyPass = "http://127.0.0.1:9696"; }; };
        "transmission.${ivi.domain}"  = { locations."/" = { proxyPass = "http://127.0.0.1:9091"; }; };
        "sabnzb.${ivi.domain}"  = { locations."/" = { proxyPass = "http://127.0.0.1:8080"; }; };
        "lazylibrarian.${ivi.domain}"  = { locations."/" = { proxyPass = "http://127.0.0.1:5299"; }; };
        "plex.${ivi.domain}"  = { locations."/" = { proxyPass = "http://127.0.0.1:32400"; }; };
      };
  };
  services = {
      plex = { enable = true; group = "multimedia"; };
      sonarr = { enable = true; group = "multimedia"; };
      radarr = { enable = true; group = "multimedia"; };
      bazarr = { enable = true; group = "multimedia"; };
      readarr = { enable = true; group = "multimedia"; };
      prowlarr = { enable = true; };
  };
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      transmission = {
        image = "haugene/transmission-openvpn";
        extraOptions = ["--cap-add=NET_ADMIN"];
        volumes = [
          "/config/ovpn:/etc/openvpn/custom"
          "/config/transmission:/config"
          "/data/torrents:/data/torrents"
        ];
        ports = [
          "9091:9091"
          "5299:5299"
        ];
        environmentFiles = [
          config.secrets.transmission.path
        ];
      };
      lazylibrarian = {
        image = "linuxserver/lazylibrarian";
        extraOptions = ["--network=container:transmission"];
        volumes = [
          "/config/lazylibrarian:/config"
          "/data:/data"
        ];
        environment = {
          PUID="1000";
          PGID="1000";
          TZ="Etc/UTC";
          DOCKER_MODS="linuxserver/mods:lazylibrarian-ffmpeg";
        };
      };
      # sabnzbdvpn = {
      #   image = "linuxserver/sabnzbd";
      #   extraOptions = ["--network=container:transmission"];
      #   volumes = [
      #     "/sabnzb/data:/data"
      #     "/sabnzb/config:/config"
      #     "/etc/localtime:/etc/localtime:ro"
      #   ];
      #   ports = [
      #     "8080:8080"
      #     "8090:8090"
      #     "8118:8118"
      #   ];
      #   environmentFiles = [
      #     config.secrets.sabnzb.path
      #   ];
      # };
    };
  };
}
