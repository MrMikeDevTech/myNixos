{ noctalia, ... }:

{
  imports = [ noctalia.homeModules.default ];

  programs.noctalia = {
    enable = true;
    systemd.enable = true;

    settings = {
      shell = {
        font = "JetBrainsMono Nerd Font";
      };
      theme = {
        mode = "dark";
        source = "wallpaper";
      };
      brightness = {
        minimum_brightness = 0.05;
      };

      widget = {
        # oculta el SSID, deja solo el ícono
        network = {
          show_label = false;
        };

        battery = {
          display_mode = "glyph";
          show_label = true;
          label_content = "percent";
        };
      };

      # reemplaza al swayidle de niri.nix; así sí respeta el botón "caffeine"
      idle = {
        behavior = {
          lock = {
            timeout = 300;
            action = "lock";
            enabled = true;
          };
          "screen-off" = {
            timeout = 600;
            action = "screen_off";
            enabled = true;
          };
        };
      };
    };
  };
}
