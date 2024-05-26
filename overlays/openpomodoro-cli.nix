{pkgs, lib, ...}: (final: prev:
  with pkgs; {
    openpomodoro-cli = buildGoModule rec {
      pname = "openpomodoro-cli";
      version = "0.3.0";

      src = fetchFromGitHub {
        owner = "open-pomodoro";
        repo = "openpomodoro-cli";
        rev = "v${version}";
        hash = "sha256-h/o4yxrZ8ViHhN2JS0ZJMfvcJBPCsyZ9ZQw9OmKnOfY=";
      };


      vendorHash = "sha256-BR9d/PMQ1ZUYWSDO5ID2bkTN+A+VbaLTlz5t0vbkO60=";

    };
  }
)
