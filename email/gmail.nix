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
        neomutt = {
          enable = true;
          sendMailCommand = "echo 'hi'";
          mailboxName = "=== gmail ===";
          extraConfig = ''
            set spoolfile='Inbox'
          '';
        };
        mbsync = {
          enable = true;
          create = "both"; remove = "both"; expunge = "both";
          groups = {
            mailboxes = {
                channels = {
                    Inbox = { farPattern = "INBOX"; nearPattern = "INBOX"; extraConfig = { Create = "Near"; }; };
                    Archive = { farPattern = "[Gmail]/All Mail"; nearPattern = "Archive"; extraConfig = { Create = "Near"; }; };
                    Spam = { farPattern = "[Gmail]/Spam"; nearPattern = "Spam"; extraConfig = { Create = "Near"; }; };
                    Trash = { farPattern = "[Gmail]/Bin"; nearPattern = "Trash"; extraConfig = { Create = "Near"; }; };
                    Important = { farPattern = "[Gmail]/Important"; nearPattern = "Important"; extraConfig = { Create = "Near"; }; };
                    Sent = { farPattern = "[Gmail]/Sent Mail"; nearPattern = "Sent"; extraConfig = { Create = "Near"; }; };
                    FarDrafts = { farPattern = "[Gmail]/Drafts"; nearPattern = "FarDrafts"; extraConfig = { Create = "Near"; }; };
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
            ];
          };
        };
      };
    };
  };
}
