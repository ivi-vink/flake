{pkgs, ...}:
with builtins; let
  script-names = attrNames (readDir ./shell-scripts);
  package = (
    filename: let
      contents = readFile ./shell-scripts/${filename};
    in
      pkgs.writeShellScriptBin filename contents
  );
  packages = map package script-names;
in
  packages
