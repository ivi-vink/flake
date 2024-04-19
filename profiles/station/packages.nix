{
  machine,
  pkgs,
  lib,
  ...
}: with lib; {
  hm = {
    home.packages = with pkgs; [
      (nerdfonts.override {fonts = ["FiraCode" "JetBrainsMono"];})
      python311Packages.editorconfig
      calcurse
      bashInteractive
      powershell

      arduino-ide
      arduino-cli

      k9s
      krew
      azure-cli
      argocd
      (google-cloud-sdk.withExtraComponents (with google-cloud-sdk.components; [
        gke-gcloud-auth-plugin
      ]))
      imagemagick
    ] ++ (optionals (!machine.isDarwin) [
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
