{ pkgs, ... }: {
    services.mopidy = {
        enable = true;
        extensionPackages = with pkgs; [mopidy-spotify];
        extraConfigFiles = [
        ];
    };
    hm.programs.ncmpcpp = {
        enable = true;
        bindings = [
            { key = "+"; command = "show_clock"; }
        ];
    };
}
