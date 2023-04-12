{pkgs, ...}: (final: prev:
    with pkgs; {
      fennel-language-server = rustPlatform.buildRustPackage rec {
        name = "fennel-language-server";
        src = fetchGit {
          url = "https://github.com/rydesun/fennel-language-server";
          submodules = true;
          rev = "d0c65db2ef43fd56390db14c422983040b41dd9c";
          ref = "refs/heads/main";
        };
        cargoHash = "sha256-B4JV1rgW59FYUuqjPzkFF+/T+4Gpr7o4z7Cmpcszcb8=";
      };
    })
