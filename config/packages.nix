{ pkgs, ... }:

let
  # cliente HTTP de terminal (wilfredinni/noodle); no está en nixpkgs,
  # se empaqueta el binario prebuilt de la release y se le parchea el
  # dynamic linker/libs a las de nixpkgs con autoPatchelfHook.
  # ojo: v0.9.4 (release del día de hoy) subió por error el runtime de
  # Bun a secas en vez del binario de noodle; se queda fijo en v0.9.3
  noodle = pkgs.stdenv.mkDerivation rec {
    pname = "noodle";
    version = "0.9.3";

    src = pkgs.fetchurl {
      url = "https://github.com/wilfredinni/noodle/releases/download/v${version}/noodle-linux-x86_64";
      sha256 = "f449b66a7f0dfe0f5b0b2257eae1916ba28241436809ac18273ed8348221f06e";
    };

    # solo se toca el interprete: el binario es un ejecutable de Bun con el
    # script empaquetado adentro, y strip/autoPatchelfHook corrompen esos
    # bytes embebidos (Bun deja de reconocerse a sí mismo y corre como
    # bun a secas en vez de noodle)
    nativeBuildInputs = [ pkgs.patchelf ];
    dontUnpack = true;
    dontStrip = true;

    installPhase = ''
      install -Dm755 $src $out/bin/noodle
      patchelf --set-interpreter ${pkgs.stdenv.cc.libc}/lib64/ld-linux-x86-64.so.2 $out/bin/noodle
    '';

    meta = {
      description = "Cliente HTTP de terminal";
      homepage = "https://github.com/wilfredinni/noodle";
      platforms = [ "x86_64-linux" ];
    };
  };
in
{
  environment.systemPackages = with pkgs; [
    # utilidades cli
    wget
    fastfetch
    bat
    lsd
    zip
    unzip
    rar
    unrar
    figlet
    just
    cmatrix
    tree
    cava
    btop
    libva-utils
    nix-search-tv
    television
    noodle

    # editores
    vim

    # desarrollo
    git
    cargo
    gcc
    python3
    python3Packages.pip
    bun
    claude-code
    docker
    docker-compose

    # terminal y wayland
    kitty
    xwayland-satellite

    # navegador y comunicación
    brave
    discord-ptb

    # multimedia
    spotify-player
    spotify
    easyeffects
    vlc
    obs-studio
    audacity

    # gaming
    steam
    snes9x
  ];
}
