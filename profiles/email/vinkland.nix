{
  inputs,
  config,
  pkgs,
  ...
}: {
  hm = {
    accounts.email = {
      accounts = {
        ivi = {
          realName = "Mike Vink";
          userName = "ivi@vinkland.xyz";
          address = "ivi@vinkland.xyz";
          passwordCommand = ["${pkgs.pass}/bin/pass" "personal/mailserver"];
          imap = { host = "vinkland.xyz"; port = 993; tls = { enable = true; }; };
          smtp = { host = "vinkland.xyz"; port = 587; tls = { enable = true; useStartTls = true; }; };
          msmtp = {
            enable = true;
          };
          neomutt = {
            enable = true;
            sendMailCommand = "msmtp -a ivi";
            mailboxName = "=== ivi ===";
            extraConfig = ''
            set spoolfile='Inbox'
            unvirtual-mailboxes *
          '';
          };
          mbsync = {
            enable = true;
            create = "both"; remove = "both"; expunge = "both";
          };
          notmuch = {
            enable = true;
            neomutt = {
              enable = true;
              virtualMailboxes = [
                { name = "Drafts"; query = "folder:/ivi/ tag:trash"; }
                { name = "Inbox"; query = "folder:/ivi/ tag:inbox"; }
                { name = "Sent"; query = "folder:/ivi/ tag:sent"; }
                { name = "Junk"; query = "folder:/ivi/ tag:trash"; }
              ];
            };
          };
        };
      };
    };
  };
}
