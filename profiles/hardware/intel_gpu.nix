{ config, lib, pkgs, ... }:

{
  # recomended graphics driver for modern intel system
  # https://nixos.org/manual/nixos/unstable/#sec-x11--graphics-cards-intel
  services.xserver = {
    videoDrivers = [ "modesetting" ];
    useGlamor = true;
  };
}
