{lib, ...}: with lib; {
  hm = {
    programs.git = {
      enable = true;
      userName = ivi.realName;
      userEmail = ivi.email;
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
