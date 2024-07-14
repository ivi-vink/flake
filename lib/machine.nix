lib: systemOptions: with lib; let
  modules = [
    {
      options.machines = mkOption {
          description = "Machine options";
          default = {};
          type = with types; attrsOf (submodule ({ name, config, ... }: {
            freeformType = attrs;
            options = {
                modules = mkOption {
                    description = "Final list of modules to import";
                    type = listOf str;
                    default = [];
                };
                profiles = mkOption {
                    description = "List of profiles to use";
                    type = listOf str;
                    default = [];
                };
                hostname = mkOption {
                    description = "The machine's hostname";
                    type = str;
                    readOnly = true;
                    default = name;
                };
                ipv4 = mkOption {
                    description = "The machines public IPv4 addresses";
                    type = listOf str;
                    default = [];
                };
                ipv6 = mkOption {
                    description = "The machines public IPv6 addresses";
                    type = listOf str;
                    default = [];
                };
                isStation = mkOption {
                    description = "The machine is a desktop station";
                    type = bool;
                    default = false;
                };
                isServer = mkOption {
                    description = "The machine is a server";
                    type = bool;
                    default = false;
                };
                isFake = mkOption {
                    description = "The machine is a fake machine";
                    type = bool;
                    default = false;
                };
                isDarwin = mkOption {
                    description = "The machine is a fake machine";
                    type = bool;
                    default = false;
                };
                tailnet = mkOption {
                  default = {};
                  type = with types; attrsOf (submodule ({ name, config, ... }: {
                    options = {
                      ipv4 = mkOption {
                          description = "The machine's tailnet IPv4 address";
                          type = str;
                          default = null;
                      };
                      ipv6 = mkOption {
                          description = "The machine's tailnet IPv6 address";
                          type = str;
                          default = null;
                      };
                      nodeKey = mkOption {
                          description = "The machine's tailnet public key";
                          type = str;
                          default = null;
                      };
                    };
                  }));
                };
                syncthing = mkOption {
                  default = {};
                  type = with types; submodule {
                    freeformType = attrs;
                    options = {
                      id = mkOption {
                          description = "The machine's syncting public id";
                          type = str;
                          default = "";
                      };
                      enable = mkEnableOption "Add to syncthing cluster";
                    };
                  };
                };
            };
          }));
      };
      config.machines = systemOptions;
    }
  ];
in (evalModules { inherit modules; }).config.machines
