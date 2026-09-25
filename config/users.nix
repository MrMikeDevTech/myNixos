{ pkgs, ... }:

{
  users.users."mrmikedev" = {
    isNormalUser = true;
    description = "MrMikeDev";
    extraGroups = [
      "networkmanager"
      "wheel"
      "bluetooth"
      "docker"
    ];
    packages = with pkgs; [ ];
    shell = pkgs.zsh;
  };
}
