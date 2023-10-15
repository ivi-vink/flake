{...}: {
  programs.tiny = {
      enable = true;
      settings = {
          servers = [
            {
              addr = "irc.libera.chat";
              port = 6697;
              tls = true;
              realname = "Mike Vink";
              nicks = [ "ivi" ];
            }
          ];
      };
      defaults = {
        nicks = [ "ivi" ];
        realname = "Mike Vink";
        join = [];
        tls = true;
      };
  };
}
