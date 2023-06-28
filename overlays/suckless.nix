{pkgs, home, ...}: (final: prev: {
    st = (prev.st.overrideAttrs (oldAttrs: rec {
      src = /. + home + "/flake/home/st";
      buildInputs = oldAttrs.buildInputs ++ [prev.harfbuzz];
    }));
    dwm = (prev.dwm.overrideAttrs (oldAttrs: rec {
      src = /. + home + "/flake/home/dwm";
    }));
    dwmblocks =(prev.stdenv.mkDerivation rec {
      pname = "dwmblocks";
      version = "1.0";
      src = /. + home + "/flake/home/dwmblocks";
      buildInputs = [prev.xorg.libX11];
      installPhase = ''
        install -m755 -D dwmblocks $out/bin/dwmblocks
      '';
    });
})
