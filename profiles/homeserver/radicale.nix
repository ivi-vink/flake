{ lib, ... }: with lib; {
  services.nginx = {
      virtualHosts."cal.${ivi.domain}"  = {
          locations."/" = {
            proxyPass = "http://127.0.0.1:5232";
          };
      };
  };
  services.radicale = {
      enable = true;
      settings.server.hosts = [ "0.0.0.0:5232" ];
  };
}
