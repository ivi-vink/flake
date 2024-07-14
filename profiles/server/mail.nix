{ inputs, config, lib, ... }: with lib; {
  imports = [
    inputs.simple-nixos-mailserver.nixosModule
  ];

  mailserver = {
    enable = true;
    enableImap = false;
    enableSubmission = true;
    enableImapSsl = true;
    enableSubmissionSsl = true;
    # TODO: configurate a local dns server?

    fqdn = my.domain;
    domains = [ my.domain ];
    loginAccounts = {
        ${my.email} = {
            hashedPasswordFile = config.secrets.my.path;
            aliases = [ "@${my.domain}" ];
        };
    };
    certificateScheme = "acme";

    lmtpSaveToDetailMailbox = "no";
  };
}
