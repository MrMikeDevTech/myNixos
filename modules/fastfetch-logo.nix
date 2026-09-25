{ pkgs, config, ... }:

let
  wallpaperLogo = pkgs.writeShellScriptBin "wallpaper-logo" ''
    set -uo pipefail

    logos_dir="$HOME/myNixos/dotfiles/fastfetch/logos"
    cache_logo="$HOME/.cache/fastfetch-logo.png"
    fastfetch_cache="$HOME/.cache/fastfetch/images$cache_logo"
    categories="komi doto cafe nishi yotsuba maomao alya rebecca reze"

    exclude_current=false
    if [ "''${1:-}" = "--exclude-current" ]; then
      exclude_current=true
      shift
    fi

    wall_path="''${1:-$(noctalia msg wallpaper-get)}"
    filename="$(basename -- "$wall_path")"
    name="''${filename%.*}"
    name="$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]')"

    matched=""
    for cat in $categories; do
      case "$name" in
        *"$cat"*) matched="$cat" ;;
      esac
      [ -n "$matched" ] && break
    done

    if [ -n "$matched" ]; then
      cat_dir="$logos_dir/$matched"
      images=()
      while IFS= read -r -d "" f; do
        images+=("$f")
      done < <(find "$cat_dir" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) -print0)

      if [ "$exclude_current" = true ] && [ -f "$cache_logo" ] && [ "''${#images[@]}" -gt 1 ]; then
        filtered=()
        for f in "''${images[@]}"; do
          ${pkgs.diffutils}/bin/cmp -s "$f" "$cache_logo" || filtered+=("$f")
        done
        [ "''${#filtered[@]}" -gt 0 ] && images=("''${filtered[@]}")
      fi

      count="''${#images[@]}"
      if [ "$count" -gt 0 ]; then
        idx=$((RANDOM % count))
        chosen="''${images[$idx]}"
        case "$chosen" in
          *.[pP][nN][gG]) cp -f "$chosen" "$cache_logo" ;;
          *) ${pkgs.imagemagick}/bin/magick "$chosen" "$cache_logo" ;;
        esac
        rm -rf "$fastfetch_cache"
        echo "wallpaper-logo: '$matched' -> $(basename -- "$chosen")"
        exit 0
      fi
    fi

    rm -f "$cache_logo"
    rm -rf "$fastfetch_cache"
    echo "wallpaper-logo: sin categoria/logo para '$filename', usando logo por defecto"
  '';

  wallpaperLogoWatch = pkgs.writeShellScriptBin "wallpaper-logo-watch" ''
    set -uo pipefail

    settings_dir="$HOME/.local/state/noctalia"
    settings_file="settings.toml"

    current_wallpaper() {
      ${pkgs.gawk}/bin/awk -F'"' '
        /^[[:space:]]*\[wallpaper\.last\]/ { f=1; next }
        f && /path[[:space:]]*=/ { print $2; exit }
      ' "$settings_dir/$settings_file" 2>/dev/null
    }

    last="$(current_wallpaper)"
    wallpaper-logo "$last" || true

    ${pkgs.inotify-tools}/bin/inotifywait -m -e close_write,moved_to -q --format '%f' "$settings_dir" |
    while read -r changed; do
      [ "$changed" = "$settings_file" ] || continue
      sleep 0.3
      current="$(current_wallpaper)"
      if [ -n "$current" ] && [ "$current" != "$last" ]; then
        last="$current"
        wallpaper-logo "$current" || true
      fi
    done
  '';
in
{
  home.packages = [
    wallpaperLogo
    wallpaperLogoWatch
  ];

  systemd.user.services.wallpaper-logo-watch = {
    Unit = {
      Description = "Actualiza el logo de fastfetch cuando cambia el wallpaper de noctalia";
      After = [
        "graphical-session.target"
        "noctalia.service"
      ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${wallpaperLogoWatch}/bin/wallpaper-logo-watch";
      Environment = "PATH=${config.home.profileDirectory}/bin:/run/current-system/sw/bin";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
