{
  pkgs,
  lib,
  ...
}: with lib; {
  hm = {
    accounts.email = {
      accounts = {
        ${ivi.username} = {
          realName = "${ivi.realName}";
          userName = "${ivi.email}";
          address = "${ivi.email}";
          passwordCommand = ["${pkgs.pass}/bin/pass" "personal/mailserver"];
          imap = { host = "${ivi.domain}"; port = 993; tls = { enable = true; }; };
          smtp = { host = "${ivi.domain}"; port = 587; tls = { enable = true; useStartTls = true; }; };
          msmtp = {
            enable = true;
          };
          neomutt = {
            enable = true;
            sendMailCommand = "msmtp -a ${ivi.username}";
            mailboxName = "=== ${ivi.username} ===";
            extraConfig = ''
            set spoolfile='Inbox'
            unvirtual-mailboxes *
          '';
          };
          mbsync = {
            enable = true;
            create = "both"; remove = "both"; expunge = "both";
            groups = {
              ${ivi.username} = {
                channels = {
                  All = { patterns = ["*"]; extraConfig = { Create = "Both"; Expunge = "Both"; Remove = "Both"; }; };
                };
              };
            };
          };
          notmuch = {
            enable = true;
            neomutt = {
              enable = true;
              virtualMailboxes = [
                { name = "Inbox"; query = "folder:/${ivi.username}/ tag:inbox"; }
                { name = "Sent"; query = "folder:/${ivi.username}/ tag:sent"; }
                { name = "Archive"; query = "folder:/${ivi.username}/ tag:archive"; }
                { name = "Drafts"; query = "folder:/${ivi.username}/ tag:drafts"; }
                { name = "Junk"; query = "folder:/${ivi.username}/ tag:spam"; }
                { name = "Trash"; query = "folder:/${ivi.username}/ tag:trash"; }
              ];
            };
          };
        };
      };
    };
  };
}
