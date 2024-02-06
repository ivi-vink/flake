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
                  type = with types; attrsOf (submodule ({ name, config, ... }: {
                    freeformType = attrs;
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
                  }));
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
          work = {
            isFake = true;
            isDarwin = true;
            profiles = [
              "core"
            ];
          };
          wsl = {
            isFake = true;
            profiles = [
              "core"
            ];
          };
          persephone = {
            isFake = true;
            tailnet = {
              ipv4 = "100.72.127.82";
              ipv6 = "fd7a:115c:a1e0::9c08:7f52";
              nodeKey = "nodekey:2ffbb54277ba6c29337807b74f69438eba4d3802bffbe9c7df4093139c087f51";
            };
          };
          bellerophone = {
            isFake = true;
            tailnet = {
              ipv4 = "100.64.230.78";
              ipv6 = "fd7a:115c:a1e0::1c0:e64e";
              nodeKey = "nodekey:3e76e1ec73bc5dcf358948ddc03aefcc349f59fdeeae513e55bd637e01c0e64d";
            };
          };
          lemptop = {
            isStation = true;
            profiles = [
              "core"
              "station"
              "email"
            ];
          };
          serber = {
            isServer = true;
            profiles = [
              "core"
              "server"
            ];
            ipv4 = [ "65.108.155.179" ];
            ipv6 = [ "2a01:4f9:c010:d2b5::1" ];
          };
          pump = {
            isServer = true;
            profiles = [
              "core"
              "homeserver"
            ];
            ipv4 = [ "192.168.2.13" ];
            ipv6 = [ "2a02:a46b:ee73:1:c240:4bcb:9fc3:71ab" ];
            tailnet = {
              ipv4 = "100.90.145.95";
              ipv6 = "fd7a:115c:a1e0::e2da:915f";
              nodeKey = "nodekey:dcd737aab30c21eb4f44a40193f3b16a8535ffe2fb5008904b39bb54e2da915e";
            };
          };
        };
      };
    }
  ];
in (evalModules { inherit modules; }).config
