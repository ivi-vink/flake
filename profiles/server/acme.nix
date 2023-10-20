{ config, lib, ... }: with lib; {
  security.acme = {
    acceptTerms = true;
    defaults = {
      extraLegoRunFlags = ["--preferred-chain" "ISRG Root X1"];
      email = ivi.email;
      dnsProvider = "porkbun";
      credentialsFile = config.secrets.porkbun.path;
    };
  };
}
