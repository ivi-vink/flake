{
  pkgs,
  lib,
  ...
}: with lib; {
  hm = {
    accounts.email = {
      accounts = {
        ${my.username} = {
          realName = "${my.realName}";
          userName = "${my.email}";
          address = "${my.email}";
          passwordCommand = ["${pkgs.pass}/bin/pass" "personal/mailserver"];
          imap = { host = "${my.domain}"; port = 993; tls = { enable = true; }; };
          smtp = { host = "${my.domain}"; port = 587; tls = { enable = true; useStartTls = true; }; };
          msmtp = {
            enable = true;
          };
          neomutt = {
            enable = true;
            sendMailCommand = "msmtp -a ${my.username}";
            mailboxName = "=== ${my.username} ===";
            extraConfig = ''
            set spoolfile='Inbox'
            unvirtual-mailboxes *
          '';
          };
          mbsync = {
            enable = true;
            create = "both"; remove = "both"; expunge = "both";
            groups = {
              ${my.username} = {
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
                { name = "Inbox"; query = "folder:/${my.username}/ tag:inbox"; }
                { name = "Sent"; query = "folder:/${my.username}/ tag:sent"; }
                { name = "Archive"; query = "folder:/${my.username}/ tag:archive"; }
                { name = "Drafts"; query = "folder:/${my.username}/ tag:drafts"; }
                { name = "Junk"; query = "folder:/${my.username}/ tag:spam"; }
                { name = "Trash"; query = "folder:/${my.username}/ tag:trash"; }
              ];
            };
          };
        };
      };
    };
  };
}
