{ lib, ... }: with lib; {
  # apparently you can set defaults on existing modules?
  options.services.nginx.virtualHosts = mkOption {
    type = types.attrsOf (types.submodule ({ name, ... }: {
      config = mkIf (name != "default") {
        forceSSL = mkDefault true;
        sslCertificateKey = "/var/lib/acme/${ivi.domain}/key.pem";
        sslCertificate = "/var/lib/acme/${ivi.domain}/fullchain.pem";
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
    };
    systemd.services.nginx.serviceConfig = {
      SupplementaryGroups = [ "acme" ];
    };
    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
