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

    fqdn = ivi.domain;
    domains = [ ivi.domain ];
    loginAccounts = {
        ${ivi.email} = {
            hashedPasswordFile = config.secrets.ivi.path;
            aliases = [ "@${ivi.domain}" ];
        };
    };
    certificateScheme = "acme";

    lmtpSaveToDetailMailbox = "no";
  };
}
