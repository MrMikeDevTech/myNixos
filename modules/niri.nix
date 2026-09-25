{
  pkgs,
  lib,
  niri-flake,
  ...
}:

{
  programs.niri.settings = {
    input = {
      keyboard.xkb.layout = "us";
      touchpad = {
        tap = true;
        natural-scroll = true;
        dwt = true;
      };
      focus-follows-mouse.enable = true;
    };

    layout = {
      gaps = 24;
      center-focused-column = "never";
      border = {
        enable = true;
        width = 3;
        active.color = "#a01ef7";
        inactive.color = "#53455a";
      };
      focus-ring.enable = false;
    };

    prefer-no-csd = true;
    hotkey-overlay.skip-at-startup = true;
    screenshot-path = "~/Pictures/Screenshots/%Y-%m-%d %H-%M-%S.png";

    window-rules = [
      {
        geometry-corner-radius =
          let
            r = 14.0;
          in
          {
            top-left = r;
            top-right = r;
            bottom-left = r;
            bottom-right = r;
          };
        clip-to-geometry = true;
      }

      {
        matches = [ { title = "^notificationtoasts_\\d+_desktop$"; } ];
        open-floating = true;
        open-focused = false;
        default-floating-position = {
          x = 16;
          y = 16;
          relative-to = "bottom-right";
        };
        border.enable = false;
        focus-ring.enable = false;
        clip-to-geometry = false;
        geometry-corner-radius = {
          top-left = 0.0;
          top-right = 0.0;
          bottom-left = 0.0;
          bottom-right = 0.0;
        };
      }

      # PiP de Chromium/Brave: sin app_id, título "Pantalla en pantalla" (es_MX)
      {
        matches = [ { app-id = "^$"; title = "^Pantalla en pantalla$"; } ];
        open-floating = true;
        default-floating-position = {
          x = 16;
          y = 16;
          relative-to = "bottom-right";
        };
      }
    ];

    binds = with pkgs; {
      # Acciones basicas
      "Mod+Return".action.spawn = "kitty";
      "Alt+Space".action.spawn-sh = "noctalia msg panel-toggle launcher";
      "Mod+Q".action.close-window = { };
      "Mod+Shift+E".action.quit = { };
      "Mod+L".action.spawn-sh = "noctalia msg session lock";

      # Cambiar el focus
      "Mod+Left".action.focus-column-left = { };
      "Mod+Right".action.focus-column-right = { };
      "Mod+Ctrl+Down".action.focus-window-down = { };
      "Mod+Ctrl+Up".action.focus-window-up = { };

      # Alternar con la ventana enfocada anteriormente
      "Alt+Tab".action.focus-window-previous = { };

      # Recolocamiento de ventanas
      "Mod+Shift+Left".action.move-column-left = { };
      "Mod+Shift+Right".action.move-column-right = { };
      "Mod+Shift+Ctrl+Down".action.move-window-down = { };
      "Mod+Shift+Ctrl+Up".action.move-window-up = { };

      # Noctalia
      "Mod+C".action.spawn-sh = "noctalia msg panel-toggle control-center";
      "Mod+Comma".action.spawn-sh = "noctalia msg settings-toggle";
      "Mod+V".action.spawn-sh = "noctalia msg panel-toggle clipboard";
      "Mod+W".action.spawn-sh = "noctalia msg panel-toggle wallpaper";
      "Mod+P".action.spawn-sh = "noctalia msg panel-toggle session";
      "Mod+N".action.spawn-sh = "noctalia msg panel-toggle control-center notifications";
      "Mod+M".action.spawn-sh = "noctalia msg panel-toggle control-center media";
      "Mod+Grave".action.spawn-sh = "noctalia msg mic-mute";

      # Aplicaciones
      "Mod+B".action.spawn = "brave";

      # Teclas de función del Blade
      "XF86AudioRaiseVolume".action.spawn-sh = "noctalia msg volume-up";
      "XF86AudioLowerVolume".action.spawn-sh = "noctalia msg volume-down";
      "XF86AudioMute".action.spawn-sh = "noctalia msg volume-mute";
      "XF86MonBrightnessUp".action.spawn-sh = "noctalia msg brightness-up";
      "XF86MonBrightnessDown".action.spawn-sh = "noctalia msg brightness-down";

      # Multimedia
      "XF86AudioPlay".action.spawn-sh = "noctalia msg media play-pause";
      "XF86AudioNext".action.spawn-sh = "noctalia msg media next";
      "XF86AudioPrev".action.spawn-sh = "noctalia msg media previous";

      # Overview
      "Mod+Tab".action.toggle-overview = { };

      # Cambiar de workspace
      "Mod+Down".action.focus-workspace-down = { };
      "Mod+Up".action.focus-workspace-up = { };

      # Mover la ventana a otro workspace
      "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = { };
      "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = { };
      "Mod+Shift+Down".action.move-column-to-workspace-down = { };
      "Mod+Shift+Up".action.move-column-to-workspace-up = { };

      # Ir a un workspace por número
      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;

      "Mod+F".action.maximize-column = { };
      "Mod+Shift+F".action.fullscreen-window = { };
      "Mod+R".action.switch-preset-column-width = { };

      # Capturas de pantalla
      "Mod+Shift+S".action.screenshot.show-pointer = false;
      "Print".action.screenshot.show-pointer = false;
      "Ctrl+Print".action.screenshot-screen.show-pointer = false;
      "Alt+Print".action.screenshot-window = { };
    };

    # procesos que arrancan junto con la sesión de niri
    # auto-lock/apagado de pantalla: migrado a noctalia.nix ([idle.behavior.*])
    spawn-at-startup = [
      { command = [ "xwayland-satellite" ]; }
    ];
  };

  home.activation.linkDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "$HOME/Pictures/Wallpapers" ]; then
      mkdir -p "$HOME/Pictures"
      ln -s "$HOME/myNixos/dotfiles/wallpapers" "$HOME/Pictures/Wallpapers"
    fi
  '';

  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
    bluetui
    prismlauncher

    (writeShellScriptBin "wall" ''
      set -e

      if [ -z "$1" ]; then
        echo "uso: wall <ruta-a-imagen>"
        exit 1
      fi

      img="$(realpath "$1")"

      noctalia msg wallpaper-set "$img"
      cp "$img" "$HOME/.cache/current-wallpaper"

      lum=$(${pkgs.imagemagick}/bin/magick "$img" -resize 1x1 -colorspace gray -format "%[fx:luminance]" info:)

      if ${pkgs.gawk}/bin/awk -v l="$lum" 'BEGIN { exit !(l < 0.45) }'; then
        noctalia msg theme-mode-set dark
        echo "luminancia: $lum -> oscuro"
      else
        noctalia msg theme-mode-set light
        echo "luminancia: $lum -> claro"
      fi

      wallpaper-logo
    '')
  ];
}
