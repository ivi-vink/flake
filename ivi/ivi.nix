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
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPZHOBNQdo5oBnQ8f147QtelhLmYItiruoNfoHF89qrJAAAABHNzaDo= ivi@lemptop"
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDqsfYS7sOLfLWvGTmxT2QYGkbXJ5kREFl42n3jtte5sLps76KECgKqEjA4OLhNZ51lKFBDzcn1QOUl3RN4+qHsBtkr+02a7hhf1bBLeb1sx6+FVXdsarln5lUF/NMcpj6stUi8mqY4aQ21jQKxZsGip9fI8fx3HtXYCVhIarRbshQlwDqTplJBLDtrnmWTprxVnz1xSZRr3euXsIh1FFQZI6klPPBa6qFJtWWtGNBCRr8Sruo6I4on7QjNyW/s1OgiNAR0N2IO9wCdjlXrjNnFEAaMrpDpZde7eULbiFP2pHYVVy/InwNhhePYkeBh/4BzlaUZVv6gXsX7wOC5OyWaXbbMzWEopbnqeXXLwNyOZ88YpN/c+kZk2/1CHl+xmlVGAr9TnZ9VST5Y4ZAEqq8OKoP3ZcchAWxWjzTgPogSfiIAP/n5xrgB+8uRZb/gkN+I7RTQKGrS2Ex7gfkj39beDeevQj3XVQ1U2kp3n+jUBHItCCpZyHISgTYW2Ct6lrziJpD0kPlAOrN3BGQtkStHYK+4EE1PrrwWGkG7Ue+tlETe8FTg+AMv1VjLV9b3pHZJCrao5/cY2MxkfGzf4HTfeueqSLSsrYuiogHAPvvzfvOV5un+dWX8HyeBjmKTBwDBFuhdca/wzk0ArHSgEYUmh2NXj/G4gaSF3EX5ZSxmMQ== ${ivi.email}"
        ];

        machines = {
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
              ipv4 = "100.123.235.65";
              ipv6 = "fd7a:115c:a1e0::bafb:eb41";
              nodeKey = "nodekey:e2a9f948a1252a4b1f1932bb99e73981fa0b7173825b54ba968f9cc0bafbeb40";
            };
            syncthing = {
              enable = true;
              id = "75U7B2F-SZOJRY2-UKAADJD-NI3R5SJ-K4J35IN-D2NJJFJ-JG5TCJA-AUERDAA";
            };
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
          work = {
            isDarwin = true;
            profiles = [
              "core"
            ];
            syncthing = {
              enable = true;
              id = "GR5MHK2-HDCFX4I-Y7JYKDN-EFTQFG6-24CXSHB-M5C6R3G-2GWX5ED-VEPAQA7";
            };
          };
          lemptop = {
            isStation = true;
            profiles = [
              "core"
              "station"
              "email"
            ];
            syncthing = {
              enable = true;
              id = "TGRWV6Z-5CJ4KRI-4VDTIUE-UA5LQYS-3ARZGNK-KL7HGXP-352PB5Q-ADTV6Q2";
            };
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
            syncthing = {
              enable = true;
              id = "7USTCMT-QZTLGPL-5FCRKJW-BZUGMOS-H7D2TTK-F4COYPG-5D7VUO2-QFME2AS";
            };
          };
        };
      };
    }
  ];
in (evalModules { inherit modules; }).config
