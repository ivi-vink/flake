{...}: {
  hm.programs.tiny = {
      enable = true;
      settings = {
          servers = [
            {
              addr = "irc.libera.chat";
              port = 6697;
              tls = true;
              realname = "Mike Vink";
              nicks = [ "ivi-v" ];
              join = ["#nixos"];
              sasl = {
                  username = "ivi-v";
                  password.command = "pass show personal/liberachat";
              };
            }
          ];
          defaults = {
            nicks = [ "ivi-v" ];
            realname = "Mike Vink";
            join = [];
            tls = true;
          };
      };
  };
}
