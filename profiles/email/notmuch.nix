{
  inputs,
  config,
  pkgs,
  ...
}: {
  programs.notmuch = {
      enable = true;
      new = {
          tags = ["new"];
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
