{pkgs, home, ...}: (final: prev: {
    st = (prev.st.overrideAttrs (oldAttrs: {
      src = /. + home + "/flake/mut/st";
      version = "0.3.1";
      buildInputs = oldAttrs.buildInputs ++ [prev.harfbuzz];
    }));
    dwm = (prev.dwm.overrideAttrs (oldAttrs: {
      src = /. + home + "/flake/mut/dwm";
      version = "0.1.4";
    }));
    dwmblocks =(prev.stdenv.mkDerivation {
      pname = "dwmblocks";
      version = "1.1.3";
      src = /. + home + "/flake/mut/dwmblocks";
      buildInputs = [prev.xorg.libX11];
      installPhase = ''
        install -m755 -D dwmblocks $out/bin/dwmblocks
      '';
    });
})
