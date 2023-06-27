{
  flake,
  config,
  pkgs,
  home-manager,
  ...
}: {
  programs.mbsync = {
      enable = true;
  };
  programs.notmuch = {
      enable = true;
      new = {
          tags = ["unread" "inbox"];
          ignore = [".mbsyncstate" ".uidvalidity"];
      };
      search.excludeTags = ["deleted" "spam"];
      maildir.synchronizeFlags = true;
      extraConfig = {
        database.path = "${config.xdg.dataHome}/mail";
        user.name = "Mike Vink";
        user.primary_email = "mike1994vink@gmail.com";
        crypto.gpg_path="gpg";
      };
  };
}
