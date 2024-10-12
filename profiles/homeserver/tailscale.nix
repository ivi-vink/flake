{ machine, config, pkgs, ... }: {
  environment.systemPackages = [ pkgs.tailscale ];
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    extraUpFlags = ["--advertise-exit-node" "--advertise-routes=${builtins.head machine.ipv4}/32"];
    authKeyFile = config.secrets.tailscale.path;
  };

  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };
}
