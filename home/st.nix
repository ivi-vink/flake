{
  flake,
  config,
  pkgs,
  home-manager,
  ...
}: let
  st-luke-smith = with pkgs; (st.overrideAttrs (oldAttrs: rec {
    src = fetchFromGitHub {
      owner = "LukeSmithxyz";
      repo = "st";
      rev = "36d225d71d448bfe307075580f0d8ef81eeb5a87";
      sha256 = "sha256-u8E8/aqbL3T4Sz0olazg7VYxq30haRdSB1SRy7MiZiA=";
    };
    buildInputs = oldAttrs.buildInputs ++ [harfbuzz];
  }));
in {
  home.packages = [
    st-luke-smith
  ];
}
