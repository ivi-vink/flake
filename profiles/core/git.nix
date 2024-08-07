{config,lib, ...}: with lib;
{
  hm = {
    programs.git = {
      enable = true;
      userName = my.realName;
      userEmail = if config.networking.hostName == "work" then "mike@pionative.com" else my.email;
      extraConfig = {
        worktree.guessRemote = true;
        mergetool.fugitive.cmd = "vim -f -c \"Gdiff\" \"$MERGED\"";
        merge.tool = "fugitive";
        gpg.format = "ssh";
        user.signingKey = "${config.my.home}/.ssh/id_ed25519_sk.pub";
        commit.gpgsign = true;
      };

      ignores = [
        "/.direnv/"
        "/.envrc"
        "/.env"
        ".vimsession.vim"
        "tfplan"
        "plan"
      ];
    };
  };
}
