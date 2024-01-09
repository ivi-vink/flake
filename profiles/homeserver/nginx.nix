{ lib, ... }: with lib; {
  # apparently you can set defaults on existing modules?
  options.services.nginx.virtualHosts = mkOption {
    type = types.attrsOf (types.submodule ({ name, ... }: {
      config = mkIf (name != "default") {
        forceSSL = mkDefault true;
        sslCertificateKey = "/var/lib/acme/vinkies.net/key.pem";
        sslCertificate = "/var/lib/acme/vinkies.net/fullchain.pem";
      };
    }));
  };
  config = {
    services.nginx = {
      enable = true;
      enableReload = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      virtualHosts."cal.${ivi.domain}"  = {
          locations."/" = {
            proxyPass = "http://127.0.0.1:5232";
          };
      };
    };
    systemd.services.nginx.serviceConfig = {
      SupplementaryGroups = [ "acme" ];
    };
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    services.radicale = {
        enable = true;
        settings.server.hosts = [ "0.0.0.0:5232" ];
    };
  };
}
