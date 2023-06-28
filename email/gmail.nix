{
  flake,
  config,
  pkgs,
  home-manager,
  ...
}: {
  accounts.email = {
    maildirBasePath = "${config.xdg.dataHome}/mail";
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
          mailboxName = "=== gmail ===";
          extraConfig = ''
            set spoolfile='Inbox'
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
              { name = "Inbox"; query = "tag:inbox"; }
              { name = "Archive"; query = "tag:archive"; }
              { name = "Sent"; query = "tag:sent"; }
              { name = "Spam"; query = "tag:spam"; }
              { name = "Trash"; query = "tag:trash"; }
              { name = "Jobs"; query = "tag:jobs"; }
              { name = "Houses"; query = "tag:houses"; }
              { name = "Development"; query = "tag:dev"; }
            ];
          };
        };
      };
    };
  };
}
