{ pkgs, lib, ... }: with lib; {
  environment.systemPackages = with pkgs; mkIf (!pkgs.stdenv.isDarwin) [
    virt-viewer
  ];
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  hm.dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
  my.extraGroups = [ "libvirtd" ];
}
