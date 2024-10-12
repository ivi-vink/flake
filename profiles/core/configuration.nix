{
  machine,
  config,
  pkgs,
  lib,
  ...
}: with lib; {
  imports = [ (mkAliasOptionModule [ "my" ] [ "users" "users" my.username ]) ];

  services = {
    resolved.fallbackDns = [
      "1.1.1.1#one.one.one.one"
      "1.0.0.1#one.one.one.one"
      "2606:4700:4700::1111#one.one.one.one"
      "2606:4700:4700::1001#one.one.one.one"
    ];
  };
  security = {
    sudo = {
      wheelNeedsPassword = false;
      extraConfig = ''
        Defaults env_keep+="EDITOR"
        Defaults env_keep+="SSH_CONNECTION SSH_CLIENT SSH_TTY"
        Defaults env_keep+="http_proxy https_proxy"
      '';
    };
  };

  time.timeZone = "Europe/Amsterdam";
  users.users = {
      ${my.username} = {
        uid = mkIf (!machine.isDarwin) 1000;
        description = my.realName;
        openssh.authorizedKeys.keys = my.sshKeys;
        extraGroups = ["wheel" "networkmanager" "docker" "transmission" "dialout" "test" "libvirtd"];
        isNormalUser = true;
      };
      root = {
        openssh.authorizedKeys.keys = config.my.openssh.authorizedKeys.keys;
      };
  };

  nix.package = pkgs.nixVersions.latest;
  nix.extraOptions = ''
    experimental-features = nix-command flakes configurable-impure-env
  '';

  hm.xdg.configFile."gtk-2.0/gtkrc".text = ''
    gtk-key-theme-name = "Emacs"
  '';

  hm.xdg.configFile."gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-key-theme-name = Emacs
  '';
}
