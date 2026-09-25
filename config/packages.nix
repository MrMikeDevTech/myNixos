{ pkgs, ... }:

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
