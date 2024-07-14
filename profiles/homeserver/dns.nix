{ config, machines, machine, inputs, lib, ... }: with lib; let
    dns = inputs.dns.lib;
  in {
  system.extraDependencies = collectFlakeInputs inputs.dns;
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
  services.unbound = {
    enable = true;
    localControlSocketPath = "/run/unbound/unbound.ctl";
    settings = {
      server = {
        tls-system-cert = true;
        interface = [
          "0.0.0.0" "::"
        ];
        do-not-query-localhost = false;
        access-control = [
          "192.168.2.0/24 allow"
          "100.0.0.0/8 allow"
        ];
      };
      stub-zone = [ {
        name = my.domain;
        stub-addr = "127.0.0.1@10053";
      } ];
      forward-zone = [
      {
        name = "_acme-challenge.${my.domain}";
        forward-addr = config.services.resolved.fallbackDns;
        forward-tls-upstream = true;
      }
      {
        name = ".";
        forward-addr = config.services.resolved.fallbackDns;
        forward-tls-upstream = true;
      } ];
    };
  };
  networking.nameservers = [ "127.0.0.1" "::1" ];
  services.nsd = {
    enable = true;
    interfaces = ["127.0.0.1@10053"];
    ipTransparent = true;
    ratelimit.enable = true;

    zones = with dns.combinators; let
      here = {
        A = map a machines.serber.ipv4;
        AAAA = map a machines.serber.ipv6;
      };
    in {
      ${my.domain}.data = dns.toString my.domain (here // {
        TTL = 60 * 60;
        SOA = {
            nameServer = "@";
            adminEmail = "dns@${my.domain}";
            serial = 0;
        };
        NS = [ "@" ];
        subdomains = {
          "*" = {A = map a machine.ipv4;};
        };
      });
    };
  };
}
