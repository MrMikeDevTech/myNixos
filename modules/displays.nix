{ pkgs, ... }:

{
  programs.niri.settings.binds = with pkgs; {
    "Mod+F1".action.spawn-sh = "display-mode screen-only";
    "Mod+F2".action.spawn-sh = "display-mode mirror";
    "Mod+F3".action.spawn-sh = "display-mode extend";
    "Mod+Shift+D".action.spawn = "nwg-displays";
  };

  home.packages = with pkgs; [
    nwg-displays
    wl-mirror

    (writeShellScriptBin "display-mode" ''
      set -e

      mode="$1"
      if [ "$mode" != "screen-only" ] && [ "$mode" != "mirror" ] && [ "$mode" != "extend" ]; then
        echo "uso: display-mode <screen-only|mirror|extend>"
        exit 1
      fi

      pkill -x wl-mirror >/dev/null 2>&1 || true

      outputs_json="$(niri msg --json outputs)"
      names=($(${pkgs.jq}/bin/jq -r 'keys[]' <<< "$outputs_json"))

      primary=""
      secondary=""
      for name in "''${names[@]}"; do
        if [[ "$name" == eDP-* ]]; then
          primary="$name"
        fi
      done
      if [ -z "$primary" ]; then
        primary="''${names[0]}"
      fi
      for name in "''${names[@]}"; do
        if [ "$name" != "$primary" ]; then
          secondary="$name"
          break
        fi
      done

      if [ "$mode" = "screen-only" ]; then
        if [ -n "$secondary" ]; then
          niri msg output "$secondary" off
        fi
        exit 0
      fi

      if [ -z "$secondary" ]; then
        echo "no hay un segundo monitor conectado"
        exit 1
      fi

      niri msg output "$secondary" on

      primary_width=$(${pkgs.jq}/bin/jq -r --arg o "$primary" '.[$o].logical.width' <<< "$outputs_json")
      niri msg output "$secondary" position "$primary_width" 0

      if [ "$mode" = "mirror" ]; then
        nohup ${pkgs.wl-mirror}/bin/wl-mirror "$primary" --fullscreen-output "$secondary" \
          >/dev/null 2>&1 &
        disown
      fi
    '')
  ];
}
