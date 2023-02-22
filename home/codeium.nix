{
  flake,
  config,
  pkgs,
  home-manager,
  ...
}: let
  codeium = with pkgs; stdenv.mkDerivation rec {
    pname = "codeium";
    version = "1.1.39";

    ls-sha = "c8fda9657259bb7f3d432c1b558db921db4257aa";

    src = fetchurl {
      url = "https://github.com/Exafunction/codeium/releases/download/language-server-v${version}/language_server_linux_x64.gz";
      sha256 = "sha256-LA1VVW4X30a8UD9aDUCTmBKVXM7G0WE7dSsZ73TaaVo=";
    };

    nativeBuildInputs = [
      autoPatchelfHook
    ];

    sourceRoot = ".";

    unpackPhase = ''
      cp $src language_server_linux_x64.gz
      gzip -d language_server_linux_x64.gz
    '';

    installPhase = ''
      install -m755 -D language_server_linux_x64 $out
    '';

    preFixup = ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      $out
    '';

    meta = with lib; {
      homepage = "https://www.codeium.com/";
      description = "Codeium language server";
      platforms = platforms.linux;
    };
  };
in {
  home.activation = {
    # links codeium into place
    codium-symlink = home-manager.lib.hm.dag.entryAfter ["writeBoundary"] ''
      CODEIUM_TARGET="${config.home.homeDirectory}/.codeium/bin/c8fda9657259bb7f3d432c1b558db921db4257aa"
      if [ -L $CODEIUM_TARGET ] && [ -e $CODEIUM_TARGET ]; then
          $DRY_RUN_CMD echo "codeium linked"
      else
          mkdir -p $CODEIUM_TARGET
          $DRY_RUN_CMD ln -sf ${codeium} "$CODEIUM_TARGET/language_server_linux_x64"
      fi
    '';
  };
}
