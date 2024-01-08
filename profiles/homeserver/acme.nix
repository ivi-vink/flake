{ config, lib, ... }: with lib; {
  security.acme = {
    acceptTerms = true;
    defaults = {
      # NOTE(ivi): use dns wildcard certs for local services
      domain = "*.vinkies.net";
      extraLegoRunFlags = ["--preferred-chain" "ISRG Root X1"];
      email = ivi.email;
      dnsProvider = "porkbun";
      credentialsFile = config.secrets.porkbun.path;
    };
  };
}
