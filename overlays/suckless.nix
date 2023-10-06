{pkgs, home, ...}: (final: prev: {
    st = (prev.st.overrideAttrs (oldAttrs: rec {
      src = /. + home + "/flake/mut/st";
      buildInputs = oldAttrs.buildInputs ++ [prev.harfbuzz];
    }));
    dwm = (prev.dwm.overrideAttrs (oldAttrs: rec {
      src = /. + home + "/flake/mut/dwm";
    }));
    dwmblocks =(prev.stdenv.mkDerivation rec {
      pname = "dwmblocks";
      version = "1.0";
      src = /. + home + "/flake/mut/dwmblocks";
      buildInputs = [prev.xorg.libX11];
      installPhase = ''
        install -m755 -D dwmblocks $out/bin/dwmblocks
      '';
    });
})
