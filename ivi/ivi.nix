self: lib: with lib; let
  modules = [
    {
      options.machines = mkOption {
          description = "Lookup for static info needed to configure machines";
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
                isDeployed = mkOption {
                    description = "The machine is deployed with nixos";
                    type = bool;
                    default = false;
                };
            };
            config = {
              modules =
                (concatMap
                    (p: (attrValues (modulesIn (self + "/profiles/" + p))))
                    ivi.machines.${name}.profiles
                );
            };
          }));
      };
      config = {
        _module.freeformType = with types; attrs;

        username = "ivi";
        githubUsername = "ivi-vink";
        realName = "Mike Vink";
        domain = "vinkies.net";
        email = "ivi@vinkies.net";
        sshKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMT59Kbv+rO0PvB1q5u3l9wdUgsKT0M8vQ7WHnjq+kYN ${ivi.email}"
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDqsfYS7sOLfLWvGTmxT2QYGkbXJ5kREFl42n3jtte5sLps76KECgKqEjA4OLhNZ51lKFBDzcn1QOUl3RN4+qHsBtkr+02a7hhf1bBLeb1sx6+FVXdsarln5lUF/NMcpj6stUi8mqY4aQ21jQKxZsGip9fI8fx3HtXYCVhIarRbshQlwDqTplJBLDtrnmWTprxVnz1xSZRr3euXsIh1FFQZI6klPPBa6qFJtWWtGNBCRr8Sruo6I4on7QjNyW/s1OgiNAR0N2IO9wCdjlXrjNnFEAaMrpDpZde7eULbiFP2pHYVVy/InwNhhePYkeBh/4BzlaUZVv6gXsX7wOC5OyWaXbbMzWEopbnqeXXLwNyOZ88YpN/c+kZk2/1CHl+xmlVGAr9TnZ9VST5Y4ZAEqq8OKoP3ZcchAWxWjzTgPogSfiIAP/n5xrgB+8uRZb/gkN+I7RTQKGrS2Ex7gfkj39beDeevQj3XVQ1U2kp3n+jUBHItCCpZyHISgTYW2Ct6lrziJpD0kPlAOrN3BGQtkStHYK+4EE1PrrwWGkG7Ue+tlETe8FTg+AMv1VjLV9b3pHZJCrao5/cY2MxkfGzf4HTfeueqSLSsrYuiogHAPvvzfvOV5un+dWX8HyeBjmKTBwDBFuhdca/wzk0ArHSgEYUmh2NXj/G4gaSF3EX5ZSxmMQ== ${ivi.email}"
        ];

        machines = {
          lemptop = {
            secrets = true;
            addroot = true;
            profiles = [
              "core"
              "station"
              "email"
            ];
          };
          wsl = {
            addroot = false;
            secrets = false;
            profiles = [
              "core"
            ];
          };
          serber = {
            secrets = true;
            addroot = true;
            isDeployed = true;
            profiles = [
              "core"
              "server"
            ];
          };
          pump = {
            isDeployed = true;
            secrets = false;
            addroot = true;
            profiles = [
              "core"
            ];
          };
        };
      };
    }
  ];
in (evalModules { inherit modules; }).config
