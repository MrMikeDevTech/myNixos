{ pkgs, ... }:

{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        type = "kitty";
        source = "/home/mrmikedev/.cache/fastfetch-logo.png";
        width = 30;
        height = 15;
        padding.top = 2;
      };
      display = {
        separator = " → ";
        constants = [
          "────────────────────────"
          "──────────────────────"
          "                                                                      "
        ];
      };
      modules = [
        {
          type = "title";
          format = "{##6c7086}┌──────────────────{#} {##f38ba8}{#} {##cba6f7}Mr{##f5c2e7}Mike{##89b4fa}Dev{#} {##6c7086}//{#} {##89b4fa}{2}{#} {##6c7086}───────────────────┐{#}";
        }
        {
          type = "custom";
          format = "{##6c7086}│{$3}│{#}";
        }
        {
          type = "custom";
          format = "{##6c7086}├{$1}{#} {##cba6f7}Hardware Information{#} {##6c7086}{$1}┤{#}";
        }
        {
          type = "custom";
          format = "{##6c7086}│{$3}│{#}";
        }
        {
          type = "host";
          key = " Host";
        }
        {
          type = "cpu";
          key = " CPU";
        }
        {
          type = "gpu";
          key = "󰢮 GPU";
        }
        {
          type = "memory";
          key = "󰍛 Memory";
        }
        {
          type = "disk";
          key = "󰋊 Disk";
        }
        {
          type = "display";
          key = "󰍹 Display";
        }

        {
          type = "custom";
          format = "{##6c7086}├{$1}{#} {##89b4fa}Software Information{#} {##6c7086}{$1}┤{#}";
        }
        {
          type = "os";
          key = " OS";
        }
        {
          type = "kernel";
          key = " Kernel";
        }
        {
          type = "wm";
          key = "󰖲 WM";
        }
        {
          type = "shell";
          key = " Shell";
        }
        {
          type = "terminal";
          key = " Terminal";
        }
        {
          type = "font";
          key = " Font";
        }
        {
          type = "icons";
          key = "󰀻 Icons";
        }
        {
          type = "packages";
          key = "󰏗 Packages";
        }
        {
          type = "uptime";
          key = " Uptime";
        }
        {
          type = "localip";
          key = "󰩠 Local IP";
        }
        {
          type = "battery";
          key = " Battery";
        }

        {
          type = "custom";
          format = "{##6c7086}│{$3}│{#}";
        }
        {
          type = "custom";
          format = "{##6c7086}└{$1}{$2}{$1}┘{#}";
        }
        {
          type = "colors";
          paddingLeft = 2;
          symbol = "circle";
        }
      ];
    };
  };
}
