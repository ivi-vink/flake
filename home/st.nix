{
  flake,
  config,
  pkgs,
  home-manager,
  ...
}: let
  st-fork = with pkgs; (st.overrideAttrs (oldAttrs: rec {
    src = fetchFromGitHub {
      owner = "mvinkio";
      repo = "st";
      rev = "67b580fc4f0bbe1862caf5e71f14b768036904c2";
      sha256 = "sha256-60ougrGKYL7uwfxePi/YhkHCihlLiwAomh0hpVAcRtg=";
    };
    buildInputs = oldAttrs.buildInputs ++ [harfbuzz];
  }));
in {
  home.packages = [
    st-fork
  ];
}
