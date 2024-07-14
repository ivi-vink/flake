{ config, lib, ... }: with lib; {
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  users.groups.multimedia = { };
  users.users.${my.username}.extraGroups = [ "multimedia" ];

  systemd.tmpfiles.rules = [
    "d /data 0770 - multimedia - -"
  ];

  services.nginx = {
    virtualHosts = {
      "sonarr.${my.domain}"  = { locations."/" = { proxyPass = "http://127.0.0.1:8989"; }; };
      "radarr.${my.domain}"  = { locations."/" = { proxyPass = "http://127.0.0.1:7878"; }; };
      "bazarr.${my.domain}"  = { locations."/" = { proxyPass = "http://127.0.0.1:${toString config.services.bazarr.listenPort}"; }; };
      # "readarr.${my.domain}"  = { locations."/" = { proxyPass = "http://127.0.0.1:8787"; }; };
      "prowlarr.${my.domain}"  = { locations."/" = { proxyPass = "http://127.0.0.1:9696"; }; };
      "transmission.${my.domain}"  = { locations."/" = { proxyPass = "http://127.0.0.1:9091"; }; };
      "jellyfin.${my.domain}"  = { locations."/" = { proxyPass = "http://127.0.0.1:8096"; }; };
    };
  };
  # services = {
  #   jellyfin = { enable = true; group = "multimedia"; };
  #   sonarr = { enable = true; group = "multimedia"; };
  #   radarr = { enable = true; group = "multimedia"; };
  #   bazarr = { enable = true; group = "multimedia"; };
  #   readarr = { enable = true; group = "multimedia"; };
  #   prowlarr = { enable = true; };
  # };
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      prowlarr = {
        image = "linuxserver/prowlarr";
        extraOptions = ["--net=host"];
        volumes = [
          "/data/config/prowlarr/data:/config"
        ];
      };
      bazarr = {
        image = "linuxserver/bazarr";
        extraOptions = ["--net=host"];
        volumes = [
          "/data/media:/data"
          "/data/config/prowlarr/data:/config"
        ];
      };
      radarr = {
        image = "linuxserver/radarr";
        extraOptions = ["--net=host"];
        volumes = [
          "/data/media:/data"
          "/data/config/radarr/data:/config"
        ];
      };
      sonarr = {
        image = "linuxserver/sonarr";
        extraOptions = ["--net=host"];
        volumes = [
          "/data/media:/data"
          "/data/config/sonarr/data:/config"
        ];
      };
      jellyfin = {
        image = "jellyfin/jellyfin";
        extraOptions = ["--net=host"];
        volumes = [
          "/data/config/jellyfin/config:/config"
          "/data/config/jellyfin/cache:/config"
        ];
      };
      transmission = {
        image = "haugene/transmission-openvpn";
        extraOptions = ["--cap-add=NET_ADMIN"];
        volumes = [
          "/data/config/ovpn:/etc/openvpn/custom"
          "/data/config/transmission:/config"
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
    };
  };
}
