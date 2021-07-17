{ config, lib, pkgs, ... }:
let
  ifGui = lib.mkIf config.services.xserver.enable;

  cli-imports = [
    ../profiles/xdg
    ../profiles/direnv
    ../profiles/firefox
    ../profiles/texlive
  ];
  my-imports = cli-imports;

  cli-packages = with pkgs; [
  ];
  gui-packages = with pkgs; [
    calibre
    libreoffice-fresh
    inkscape
    gimp
    schildichat-desktop
    jitsi-meet-electron
    tdesktop
    discord
    zoom-us
  ];
  my-packages =
    if config.services.xserver.enable
    then cli-packages ++ gui-packages
    else cli-packages;
in
{
  home-manager.users.camillo = {
    imports = my-imports;

    home.packages = my-packages;
  };


  users.users.camillo = {
    uid = 1001;
    hashedPassword = "$6$OtFhvqOYcPly$ezUoArEEAmmQVg6BWfrqXRQGhGl7C2DEpcYGeaCvYyDkdbm0PuHUn4IMN/N8Fln6ckC/nHbkoR6ihvXRnkRrQ0";
    description = "Camillo Tissot";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "input" ];
    shell = pkgs.zsh;
  };

}
