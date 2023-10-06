{
  inputs,
  flake,
  config,
  pkgs,
  ...
}:
  let
    kakouneWithPlugins = pkgs.wrapKakoune pkgs.kakoune-unwrapped {
      configure = {
        plugins = with pkgs.kakounePlugins; [kak-lsp parinfer-rust];
      };
    };
  in {
    hm = {
      home.packages = [kakouneWithPlugins];
    };
}
