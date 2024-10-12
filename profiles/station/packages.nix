{
  machine,
  pkgs,
  lib,
  ...
}: with lib; {
  hm = {
    home.packages = with pkgs; [
      python311Packages.editorconfig
      calcurse
      bashInteractive
      powershell

      k9s
      krew
      azure-cli
      argocd
      (google-cloud-sdk.withExtraComponents (with google-cloud-sdk.components; [
        gke-gcloud-auth-plugin
      ]))
      imagemagick
      poppler_utils
      inkscape
    ] ++ (optionals (!machine.isDarwin) [
      arduino-ide
      arduino-cli
      xdotool
      pywal
      dasel
      inotify-tools
      raylib
      maim
      profanity
      mypaint
      lynx
      sent
      initool
      dmenu
      librewolf
      firefox-wayland
      libreoffice
      xclip
    ]);
  };
}
