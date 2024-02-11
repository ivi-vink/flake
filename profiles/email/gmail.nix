{
  config,
  pkgs,
  ...
}: {
  hm = {
    accounts.email = {
      maildirBasePath = "${config.hm.xdg.dataHome}/mail";
      accounts = {
        gmail = {
          primary = true;
          realName = "Mike Vink";
          userName = "mike1994vink@gmail.com";
          address = "mike1994vink@gmail.com";
          passwordCommand = ["${pkgs.pass}/bin/pass" "personal/neomutt"];
          imap = { host = "imap.gmail.com"; port = 993; tls = { enable = true; }; };
          smtp = { host = "smtp.gmail.com"; port = 587; tls = { enable = true; useStartTls = true; }; };
          msmtp = {
            enable = true;
          };
          neomutt = {
            enable = true;
            sendMailCommand = "msmtp -a gmail";
            mailboxName = "=== mike1994vink ===";
            extraConfig = ''
            set spoolfile='Inbox'
            unvirtual-mailboxes *
          '';
          };
          mbsync = {
            enable = true;
            create = "both"; remove = "both"; expunge = "both";
            groups = {
              gmail = {
                channels = {
                  Inbox = { farPattern = "INBOX"; nearPattern = "INBOX"; extraConfig = { Create = "Near"; Expunge = "Both"; }; };
                  Archive = { farPattern = "[Gmail]/All Mail"; nearPattern = "Archive"; extraConfig = { Create = "Near"; Expunge = "Both"; }; };
                  Spam = { farPattern = "[Gmail]/Spam"; nearPattern = "Spam"; extraConfig = { Create = "Near"; Expunge = "Both"; }; };
                  Trash = { farPattern = "[Gmail]/Bin"; nearPattern = "Trash"; extraConfig = { Create = "Near"; Expunge = "Both"; }; };
                  Important = { farPattern = "[Gmail]/Important"; nearPattern = "Important"; extraConfig = { Create = "Near"; Expunge = "Both"; }; };
                  Sent = { farPattern = "[Gmail]/Sent Mail"; nearPattern = "Sent"; extraConfig = { Create = "Near"; Expunge = "Both"; }; };
                  FarDrafts = { farPattern = "[Gmail]/Drafts"; nearPattern = "FarDrafts"; extraConfig = { Create = "Near"; Expunge = "Both"; }; };
                };
              };
            };
          };
          notmuch = {
            enable = true;
            neomutt = {
              enable = true;
              virtualMailboxes = [
                { name = "Inbox"; query = "folder:/gmail/ tag:inbox"; }
                { name = "Archive"; query = "folder:/gmail/ tag:archive"; }
                { name = "Sent"; query = "folder:/gmail/ tag:sent"; }
                { name = "Spam"; query = "folder:/gmail/ tag:spam"; }
                { name = "Trash"; query = "folder:/gmail/ tag:trash"; }
                { name = "Jobs"; query = "folder:/gmail/ tag:jobs"; }
                { name = "Houses"; query = "folder:/gmail/ tag:houses"; }
                { name = "Development"; query = "folder:/gmail/ tag:dev"; }
              ];
            };
          };
        };
        family = {
          primary = false;
          realName = "Natalia & Mike Vink";
          userName = "natalia.mike.vink@gmail.com";
          address = "natalia.mike.vink@gmail.com";
          passwordCommand = ["${pkgs.pass}/bin/pass" "personal/neomutt-family"];
          imap = { host = "imap.gmail.com"; port = 993; tls = { enable = true; }; };
          smtp = { host = "smtp.gmail.com"; port = 587; tls = { enable = true; useStartTls = true; }; };
          msmtp = {
            enable = true;
          };
          neomutt = {
            enable = true;
            sendMailCommand = "msmtp -a family";
            mailboxName = "=== family ===";
            extraConfig = ''
            set spoolfile='Inbox'
            unvirtual-mailboxes *
          '';
          };
          mbsync = {
            enable = true;
            create = "both"; remove = "both"; expunge = "both";
            groups = {
              family = {
                channels = {
                  Inbox = { farPattern = "INBOX"; nearPattern = "INBOX"; extraConfig = { Create = "Near"; Expunge = "Both"; }; };
                  Archive = { farPattern = "[Gmail]/All Mail"; nearPattern = "Archive"; extraConfig = { Create = "Near"; Expunge = "Both"; }; };
                  Spam = { farPattern = "[Gmail]/Spam"; nearPattern = "Spam"; extraConfig = { Create = "Near"; Expunge = "Both"; }; };
                  Trash = { farPattern = "[Gmail]/Trash"; nearPattern = "Trash"; extraConfig = { Create = "Near"; Expunge = "Both"; }; };
                  Important = { farPattern = "[Gmail]/Important"; nearPattern = "Important"; extraConfig = { Create = "Near"; Expunge = "Both"; }; };
                  Sent = { farPattern = "[Gmail]/Sent Mail"; nearPattern = "Sent"; extraConfig = { Create = "Near"; Expunge = "Both"; }; };
                  FarDrafts = { farPattern = "[Gmail]/Drafts"; nearPattern = "FarDrafts"; extraConfig = { Create = "Near"; Expunge = "Both"; }; };
                };
              };
            };
          };
          notmuch = {
            enable = true;
            neomutt = {
              enable = true;
              virtualMailboxes = [
                { name = "Inbox"; query = "folder:/family/ tag:inbox"; }
                { name = "Archive"; query = "folder:/family/ tag:archive"; }
                { name = "Sent"; query = "folder:/family/ tag:sent"; }
                { name = "Spam"; query = "folder:/family/ tag:spam"; }
                { name = "Trash"; query = "folder:/family/ tag:trash"; }
              ];
            };
          };
        };
      };
    };
  };
}
