{pkgs,...}: {
  hm.home.packages = [pkgs.ueberzugpp pkgs.lf pkgs.nsxiv];
  hm.xdg.configFile = {
    # "lf/cleaner".source = config.lib.meta.mkMutableSymlink /mut/lf/cleaner;
    # "lf/scope".source = config.lib.meta.mkMutableSymlink /mut/lf/scope;
    # "lf/lfrc".source = config.lib.meta.mkMutableSymlink /mut/lf/lfrc;
    #"lf/icons".text = ''
    #'';
  };
}
