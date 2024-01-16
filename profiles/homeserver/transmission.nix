{ config, lib, pkgs, ... }: with lib; {
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

  environment.systemPackages = [
    pkgs.jellyfin-ffmpeg
  ];

  services.nginx = {
    virtualHosts = {
      "sonarr.${ivi.domain}"  = { locations."/" = { proxyPass = "http://127.0.0.1:8989"; }; };
      "radarr.${ivi.domain}"  = { locations."/" = { proxyPass = "http://127.0.0.1:7878"; }; };
      "bazarr.${ivi.domain}"  = { locations."/" = { proxyPass = "http://127.0.0.1:${toString config.services.bazarr.listenPort}"; }; };
      "readarr.${ivi.domain}"  = { locations."/" = { proxyPass = "http://127.0.0.1:8787"; }; };
      "prowlarr.${ivi.domain}"  = { locations."/" = { proxyPass = "http://127.0.0.1:9696"; }; };
      "transmission.${ivi.domain}"  = { locations."/" = { proxyPass = "http://127.0.0.1:9091"; }; };
      "jellyfin.${ivi.domain}"  = { locations."/" = { proxyPass = "http://127.0.0.1:8096"; }; };
    };
  };
  services = {
    jellyfin = { enable = true; group = "multimedia"; };
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
          "8081:80"
        ];
        environmentFiles = [
          config.secrets.transmission.path
        ];
      };
      # ytdl-sub = {
      #   image = "ghcr.io/jmbannon/ytdl-sub:latest";
      #   environment = {
      #     TZ="";
      #     DOCKER_MODS="linuxserver/mods:universal-cron";
      #   };
      # };
    };
  };
}
