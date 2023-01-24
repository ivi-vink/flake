{pkgs, config, ...}:
with builtins; let
  script-names = attrNames (readDir ./shell-scripts);
  package = (
    filename: with pkgs; let
    in
      stdenv.mkDerivation {
        name = filename;

        buildCommand = ''
          install -Dm755 $script $out/bin/${filename}
        '';

        script = substituteAll {
          src = ./shell-scripts/${filename};
          isExecutable = true;
          inherit bash;
          home = config.home.homeDirectory;
        };
      }
  );
  packages = map package script-names;
in
  packages
