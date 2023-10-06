{config, ...}: {
  hm = {
    programs.git = {
      enable = true;
      userName = "Mike Vink";
      userEmail = "mike1994vink@gmail.com";
      extraConfig = {
        worktree.guessRemote = true;
        mergetool.fugitive.cmd = "vim -f -c \"Gdiff\" \"$MERGED\"";
        merge.tool = "fugitive";
      };
      ignores = [
        "/.direnv/"
        "/.envrc"
        "/.env"
        ".vimsession.vim"
      ];
    };
  };
}
