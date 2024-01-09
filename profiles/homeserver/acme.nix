{ config, lib, ... }: with lib; {
  security.acme = {
    acceptTerms = true;
    defaults = {
      extraLegoRunFlags = ["--preferred-chain" "ISRG Root X1"];
      email = ivi.email;
      dnsProvider = "porkbun";
      environmentFile = config.secrets.porkbun.path;
    };
    certs."${ivi.domain}" = {
      # NOTE(ivi): use dns wildcard certs for local services
      domain = "*.${ivi.domain}";
    };
  };
}
