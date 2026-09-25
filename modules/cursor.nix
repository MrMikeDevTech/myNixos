{ pkgs, ... }:

let
  theme-name = "pixloen-manhattan-cafe";
  cursor-theme = pkgs.stdenvNoCC.mkDerivation {
    pname = theme-name;
    version = "1.9";
    src = ../dotfiles/cursors/pixloen-manhattan-cafe;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/icons/${theme-name}
      cp -r cursors $out/share/icons/${theme-name}/
      cp index.theme $out/share/icons/${theme-name}/
    '';
  };
in
{
  home.pointerCursor = {
    enable = true;
    package = cursor-theme;
    name = theme-name;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
}
