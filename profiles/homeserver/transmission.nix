{
  config,
  lib,
  ...
}:
with lib; let
  multimediaUsernames = [
    "prowlarr"
    "sonarr"
    "radarr"
    "bazarr"
    "jellyfin"
    "transmission"
  ];
  mkMultimediaUsers = names:
    mergeAttrsList (imap0 (i: name: {
        ${name} = {
          uid = 2007 + i;
          isSystemUser = true;
          group = name;
          createHome = false;
        };
      })
      names);
  mkMultimediaGroups = names: mergeAttrsList (map (name: {${name} = {};}) names);
in {
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  users.groups =
    {
      multimedia = {
        gid = 1994;
        members = multimediaUsernames;
      };
    }
    // mkMultimediaGroups multimediaUsernames;
  users.users =
    {
      ${my.username}.extraGroups = ["multimedia"];
    }
    // mkMultimediaUsers multimediaUsernames;

  systemd.tmpfiles.rules = [
    "d /data 0770 - multimedia - -"
  ];

  services.nginx = {
    virtualHosts = {
      "sonarr.${my.domain}" = {locations."/" = {proxyPass = "http://127.0.0.1:8989";};};
      "radarr.${my.domain}" = {locations."/" = {proxyPass = "http://127.0.0.1:7878";};};
      "bazarr.${my.domain}" = {locations."/" = {proxyPass = "http://127.0.0.1:${toString config.services.bazarr.listenPort}";};};
      # "readarr.${my.domain}"  = { locations."/" = { proxyPass = "http://127.0.0.1:8787"; }; };
      "prowlarr.${my.domain}" = {locations."/" = {proxyPass = "http://127.0.0.1:9696";};};
      "transmission.${my.domain}" = {locations."/" = {proxyPass = "http://127.0.0.1:9091";};};
      "jellyfin.${my.domain}" = {locations."/" = {proxyPass = "http://127.0.0.1:8096";};};
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

  # TODO: use one shared data drive
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      prowlarr = {
        image = "linuxserver/prowlarr";
        extraOptions = ["--net=host"];
        environment = {
          PUID = "${toString config.users.users.prowlarr.uid}";
          PGID = "${toString config.users.groups.multimedia.gid}";
        };
        volumes = [
          # "/data/config/prowlarr/data:/config"
          "/data:/data"
        ];
      };
      bazarr = {
        image = "linuxserver/bazarr";
        extraOptions = ["--net=host"];
        environment = {
          PUID = "${toString config.users.users.bazarr.uid}";
          PGID = "${toString config.users.groups.multimedia.gid}";
        };
        volumes = [
          # "/data/media:/data"
          # "/data/config/bazarr/data:/config"
          "/data:/data"
        ];
      };
      radarr = {
        image = "linuxserver/radarr";
        extraOptions = ["--net=host"];
        environment = {
          PUID = "${toString config.users.users.radarr.uid}";
          PGID = "${toString config.users.groups.multimedia.gid}";
        };
        volumes = [
          # "/data/config/radarr/data:/config"
          "/data:/data"
        ];
      };
      sonarr = {
        image = "linuxserver/sonarr";
        extraOptions = ["--net=host"];
        environment = {
          PUID = "${toString config.users.users.sonarr.uid}";
          PGID = "${toString config.users.groups.multimedia.gid}";
        };
        volumes = [
          # "/data/config/sonarr/data:/config"
          "/data:/data"
        ];
      };
      jellyfin = {
        image = "jellyfin/jellyfin";
        extraOptions = ["--net=host"];
        user = "${toString config.users.users.jellyfin.uid}:${toString config.users.groups.multimedia.gid}";
        volumes = [
          # "/data/media:/media"
          # "/data/config/jellyfin/config:/config"
          # "/data/config/jellyfin/cache:/cache"
          "/data:/data"
        ];
      };
      transmission = {
        image = "haugene/transmission-openvpn";
        extraOptions = ["--cap-add=NET_ADMIN" "--group-add=${toString config.users.groups.multimedia.gid}"];
        volumes = [
          # "/data/config/ovpn:/etc/openvpn/custom"
          # "/data/config/transmission:/config"
          # "/data/torrents:/data/torrents"
          "/data:/data"
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
