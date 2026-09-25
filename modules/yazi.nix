{ pkgs, ... }:

{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      mgr = {
        show_hidden = false;
        sort_by = "natural";
        sort_dir_first = true;
        linemode = "size";
      };
      preview = {
        max_width = 1000;
        max_height = 1000;
      };
    };
  };

  home.packages = with pkgs; [
    ffmpeg
    p7zip
    poppler-utils
    imagemagick
  ];
}
