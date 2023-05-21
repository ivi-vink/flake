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
      rev = "e03a7d3f0b6bf4028389a82d372d0f89a922b9da";
      sha256 = "sha256-xAMChf8DepEnIhb0/GluvcWWBm9d0Pgipm9HeRi1wUk=";
    };
    buildInputs = oldAttrs.buildInputs ++ [harfbuzz];
  }));
in {
  home.packages = [
    st-fork
  ];
}
