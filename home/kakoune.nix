{
  inputs,
  flake,
  config,
  pkgs,
  ...
}:
  let
  kakouneWithPlugins = pkgs.wrapKakoune pkgs.kakoune-unwrapped { configure = { plugins = with pkgs.kakounePlugins; [kak-lsp parinfer-rust]; }; };
  in {
  home.packages = [kakouneWithPlugins];
  home.activation = {
    kakoune-symlink = inputs.home-manager.lib.hm.dag.entryAfter ["writeBoundary"] ''
      KAK_CONFIG="${config.home.homeDirectory}/kakoune"
      XDG_CONFIG_HOME_KAK="${config.xdg.configHome}/kak"
      if [ -L $XDG_CONFIG_HOME_KAK ] && [ -e $XDG_CONFIG_HOME_KAK ]; then
          $DRY_RUN_CMD echo "kakoune linked"
      else
          $DRY_RUN_CMD ln -s $KAK_CONFIG $XDG_CONFIG_HOME_KAK
      fi
      rm -rf $XDG_CONFIG_HOME_KAK/autoload/default
      ln -sf ${kakouneWithPlugins}/share/kak/autoload $XDG_CONFIG_HOME_KAK/autoload/default
    '';
  };
  home.file."${config.xdg.configHome}/kak-lsp/kak-lsp.toml" = {
      source = ./kak-lsp.toml;
  };

        #set global windowing_modules ""
        #require-module tmux
        #require-module tmux-repl
        #alias global terminal tmux-terminal-vertical
        #alias global sp new

}
