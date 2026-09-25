{ pkgs, ... }:

{
  home.packages = with pkgs; [
    television
    nix-search-tv
  ];

  home.file.".config/television/cable/nixpkgs.toml".text = ''
    [metadata]
    name = "nixpkgs"
    description = "Search Nix packages"

    [source]
    command = "nix-search-tv print"

    [preview]
    command = "nix-search-tv preview {}"
  '';
}
