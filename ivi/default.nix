self: lib: prev: with lib; {
  modulesIn = dir: pipe dir [
    builtins.readDir
    (mapAttrsToList (name: type:
      if type == "regular" && hasSuffix ".nix" name && name != "default.nix" then
        [ { name = removeSuffix ".nix" name; value = dir + "/${name}"; } ]
      else if type == "directory" && pathExists (dir + "/${name}/default.nix") then
        [ { inherit name; value = dir + "/${name}"; } ]
      else
        []
    ))
    concatLists
    listToAttrs
  ];

  # Collects the inputs of a flake recursively (with possible duplicates).
  collectFlakeInputs = input:
    [ input ] ++ concatMap collectFlakeInputs (builtins.attrValues (input.inputs or {}));

  ivi = import ./ivi.nix self lib;
}
