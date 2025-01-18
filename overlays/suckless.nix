{pkgs, home, ...}: (final: prev: {
    st = (prev.st.overrideAttrs (oldAttrs: {
      src = home + "/mut/st";
      version = "0.3.2";
      buildInputs = oldAttrs.buildInputs ++ [prev.harfbuzz];
    }));
    dwm = (prev.dwm.overrideAttrs (oldAttrs: {
      src = home + "/mut/dwm";
      version = "0.1.6";
    }));
    dwmblocks =(prev.stdenv.mkDerivation {
      pname = "dwmblocks";
      version = "1.1.4";
      src = home + "/mut/dwmblocks";
      buildInputs = [prev.xorg.libX11];
      installPhase = ''
        install -m755 -D dwmblocks $out/bin/dwmblocks
      '';
    });
    surf = (prev.surf.overrideAttrs (oldAttrs: {
      src = home + "/mut/surf";
      version = "2.1";
    }));
})
