{
  config,
  lib,
  ...
}:
with lib; {
  hm = {
    programs.git = {
      enable = true;
      userName = my.realName;
      userEmail = my.email;
      extraConfig = {
        worktree.guessRemote = true;
        mergetool.fugitive.cmd = "vim -f -c \"Gdiff\" \"$MERGED\"";
        merge.tool = "fugitive";
        gpg.format = "ssh";
        user.signingKey = "${config.my.home}/.ssh/id_ed25519_sk.pub";
        commit.gpgsign = false;
      };

      includes = let
        gh-no-reply-email = {
          user = {
            email = "59492084+ivi-vink@users.noreply.github.com";
          };
        };
      in [
        {
          condition = "hasconfig:remote.*.url:git@github.com:**/**";
          contents = gh-no-reply-email;
        }
        {
          condition = "hasconfig:remote.*.url:https://github.com/**/**";
          contents = gh-no-reply-email;
        }
      ];

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
