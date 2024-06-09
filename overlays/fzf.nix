{pkgs, lib, ...}: with pkgs; (final: prev: {
    fzf = (prev.fzf.overrideAttrs (oldAttrs: rec {
      version = "0.53.0";
      src = fetchFromGitHub {
        owner = "junegunn";
        repo = "fzf";
        rev = version;
        hash = "sha256-2g1ouyXTo4EoCub+6ngYPy+OUFoZhXbVT3FI7r5Y7Ws=";
      };
      vendorHash = "sha256-Kd/bYzakx9c/bF42LYyE1t8JCUqBsJQFtczrFocx/Ps=";
    }));
})
