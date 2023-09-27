
{
  flake,
  config,
  pkgs,
  ...
}: {
    programs.mpv = {
        enable = true;
        scripts = [
            (with pkgs; stdenv.mkDerivation rec {
               pname = "mpv-sockets";
               version = "1.0";

               src = fetchFromGitHub {
                 owner = "wis";
                 repo = "mpvSockets";
                 rev = "be9b7ca84456466e54331bab59441ac207659c1c";
                 sha256 = "sha256-tcY+cHvkQpVNohZ9yHpVlq0bU7iiKMxeUsO/BRwGzAs=";
               };

               # installFlags = [ "SCRIPTS_DIR=$(out)/share/mpv/scripts" ];
               passthru.scriptName = "mpvSockets.lua";
               installPhase = ''
                 install -m755 -D mpvSockets.lua $out/share/mpv/scripts/mpvSockets.lua
               '';

               meta = with lib; {
                 description = "mpvSockets lua module for mpv";
                 homepage = "https://github.com/wis/mpvSockets";
                 license = licenses.mit;
                 platforms = platforms.linux;
               };
            })
        ];
        config = {
            gpu-context = "drm";
        };
        bindings = {
            l="seek 5";
            h="seek -5";
            j="seek -60";
            k="seek 60";
            S="cycle sub";
        };
    };
}
