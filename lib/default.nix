inputs: lib: prev: with lib; rec {
  modulesAttrsIn = dir: pipe dir [
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

  modulesIn = dir: attrValues (modulesAttrsIn dir);

  # Collects the inputs of a flake recursively (with possible duplicates).
  collectFlakeInputs = input:
    [ input ] ++ concatMap collectFlakeInputs (builtins.attrValues (input.inputs or {}));

  my = import ./my.nix inputs.self lib;

  mkMachines = import ./machine.nix lib;

  # Gets module from ./machines/ and uses the lib to define which other modules
  # the machine needs.
  mkSystem = machines: name: systemInputs @ {
    system,
    modules,
    opts,
    ...
  }:
  let
    machine = machines.${name};
  in
  lib.nixosSystem {
    inherit lib system;
    specialArgs = {
      inherit (inputs) self;
      inherit machines machine inputs;
    };
    modules =
      modules
      ++
      (if lib.hasInfix "darwin" system then
      [inputs.home-manager.darwinModules.default]
      else
      [inputs.home-manager.nixosModules.default])
      ++ [
        ({pkgs, ...}: {
          nixpkgs.overlays = with lib; [
            (composeManyExtensions [
              (import ../overlays/vimPlugins.nix {inherit pkgs;})
              (import ../overlays/openpomodoro-cli.nix {inherit pkgs lib;})
              inputs.neovim-nightly-overlay.overlays.default
            ])
          ];
        })
      ];
  };

  mkSystems = systems:
    let
      machines = mkMachines (mapAttrs (name: value: value.opts) systems);
    in
      (mapAttrs (mkSystem machines) systems);

}
