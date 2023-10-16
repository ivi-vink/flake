{ config, pkgs, sops, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect
  ];

  system.stateVersion = "23.05";
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "vinkland";
  networking.domain = "xyz";
  services.openssh.enable = true;

  sops.secrets.porkbunCredentials = {
      format = "binary";
      sopsFile = ../../secrets/credentials/porkbun;
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      extraLegoRunFlags = ["--preferred-chain" "ISRG Root X1"];
      email = ivi.email;
      dnsProvider = "porkbun";
      credentialsFile = config.sops.secrets.porkbunCredentials.path;
    };
    certs = {
        "vinkland.xyz" = { };
    };
  };
}
