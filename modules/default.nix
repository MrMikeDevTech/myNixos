{ pkgs, ... }:

{
  imports = [
    ./audio.nix
    ./bat.nix
    ./cursor.nix
    ./displays.nix
    ./fastfetch-logo.nix
    ./fastfetch.nix
    ./kitty.nix
    ./niri.nix
    ./noctalia.nix
    ./nvim.nix
    ./television.nix
    ./yazi.nix
    ./zsh.nix
  ];

  home.homeDirectory = "/home/mrmikedev";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
