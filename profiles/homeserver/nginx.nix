{ lib, ... }: with lib; {
  # apparently you can set defaults on existing modules?
  options.services.nginx.virtualHosts = mkOption {
    type = types.attrsOf (types.submodule ({ name, ... }: {
      config = mkIf (name != "default") {
        forceSSL = mkDefault true;
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
    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
