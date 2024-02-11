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

      k9s
      krew
      azure-cli
      github-cli
      argocd
      (google-cloud-sdk.withExtraComponents (with google-cloud-sdk.components; [
        gke-gcloud-auth-plugin
      ]))
    ] ++ (optionals (!machine.isDarwin) [
      pywal
      dasel
      ueberzug
      inotify-tools
      raylib
      maim
      profanity
      mypaint
      lynx
      sxiv
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
