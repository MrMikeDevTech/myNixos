{ lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../config/nvidia.nix
    ../../config/packages.nix
    ../../config/fonts.nix
    ../../config/tailscale.nix
    ../../config/users.nix
  ];

  # arranque del sistema
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 2;

  # nix
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # garbage collector
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
    persistent = true;
  };

  # deduplica archivos idénticos en el store con hardlinks
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  # session variables
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "iHD";
  };

  # red
  networking.hostName = "mrmikedevs-nixos";
  networking.networkmanager.enable = true;

  # localización
  time.timeZone = "America/Mexico_City";
  i18n.defaultLocale = "es_MX.UTF-8";

  # nixpkgs
  nixpkgs.config.allowUnfree = true;

  # virtualización
  virtualisation.docker.enable = true;

  # steam
  programs.steam.enable = true;

  # hardware
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true;
  };

  # seguridad
  security.pam.services.swaylock = { };
  security.polkit.enable = true;

  # servicios
  services = {
    gnome.gnome-keyring.enable = true;
    gvfs.enable = true;
    upower.enable = true;
    power-profiles-daemon.enable = true;

    xserver.xkb = {
      layout = "us";
      variant = "";
    };

    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
          user = "greeter";
        };
      };
    };
  };

  # programas
  programs = {
    niri.enable = true;
    noctalia.enable = true;
    dconf.enable = true;
    zsh.enable = true;
  };

  # portal de escritorio (xdg)
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    config.niri = {
      default = [
        "gnome"
        "gtk"
      ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      "org.freedesktop.impl.portal.Screencast" = [ "gnome" ];
    };
  };

  # nvidia rendering
  hardware.nvidia.modesetting.enable = true;

  system.stateVersion = "26.05";
}
