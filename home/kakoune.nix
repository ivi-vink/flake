{
  flake,
  config,
  pkgs,
  home-manager,
  ...
}: {
  home.activation = {
    kakoune-symlink = home-manager.lib.hm.dag.entryAfter ["writeBoundary"] ''
      KAK_CONFIG="${config.home.homeDirectory}/kakoune"
      XDG_CONFIG_HOME_KAK="${config.xdg.configHome}/kak"
      if [ -L $XDG_CONFIG_HOME_KAK ] && [ -e $XDG_CONFIG_HOME_KAK ]; then
          $DRY_RUN_CMD echo "kakoune linked"
      else
          $DRY_RUN_CMD ln -s $KAK_CONFIG $XDG_CONFIG_HOME_KAK
      fi
      if [ -L   $XDG_CONFIG_HOME_KAK/autoload/default ] && [ -e  $XDG_CONFIG_HOME_KAK/autoload/default ]; then
          $DRY_RUN_CMD echo "kakoune share linked"
      else
          ln -sf ${pkgs.kakoune-unwrapped}/share/kak/autoload $XDG_CONFIG_HOME_KAK/autoload/default
      fi
    '';
  };
  programs.kakoune = {
    enable = true;
    plugins = with pkgs.kakounePlugins; [
      kak-lsp
    ];
    extraConfig = ''
        set global windowing_modules ""
        require-module tmux
        require-module tmux-repl
        alias global terminal tmux-terminal-vertical
    '';
  };
}
