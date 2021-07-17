{ config, lib, pkgs, ... }:
{
  boot.initrd.kernelModules = [
    "amdgpu"
  ];
  hardware = {
    opengl = {
      extraPackages = with pkgs; [
        rocm-opencl-icd
        rocm-opencl-runtime
        amdvlk
      ];
      driSupport = true;
    };
  };
  services.xserver.videoDrivers = [ "amdgpu" ];
}
