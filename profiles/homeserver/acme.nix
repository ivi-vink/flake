{ config, lib, ... }: with lib; {
  security.acme = {
    acceptTerms = true;
    defaults = {
      extraLegoFlags = [ "--dns.disable-cp" ];
      extraLegoRunFlags = ["--preferred-chain" "ISRG Root X1"];
      email = my.email;
      dnsProvider = "porkbun";
      environmentFile = config.secrets.porkbun.path;
    };
    certs."${my.domain}" = {
      # NOTE(ivi): use dns wildcard certs for local services
      domain = "*.${my.domain}";
    };
  };
}
