{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };
    themeFile = "Catppuccin-Mocha";
    settings = {
      background_opacity = "0.92";
      confirm_os_window_close = 0;
      window_padding_width = 10;
      cursor_shape = "beam";
      scrollback_lines = 10000;
      enable_audio_bell = false;
      tab_bar_style = "powerline";
      cursor_trail = 3;
    };

    keybindings = {
      "ctrl+left" = "send_text all \\x1b[1;5D";
      "ctrl+right" = "send_text all \\x1b[1;5C";
      "ctrl+backspace" = "send_text all \\x17";
      "ctrl+delete" = "send_text all \\x1b[3;5~";

      "shift+left" = "send_text all \\x1b[1;2D";
      "shift+right" = "send_text all \\x1b[1;2C";
      "ctrl+shift+left" = "send_text all \\x1b[1;6D";
      "ctrl+shift+right" = "send_text all \\x1b[1;6C";

      "ctrl+shift+x" = "send_text all \\x1b[120;6u";
    };
  };
}
