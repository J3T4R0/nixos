{ config, lib, pkgs, ... }:
{
  hardware.cpu.amd.updateMicrocode = true;
  boot.kernelModules = [ "kvm-amd" ];
  # HACK private PC, so performance is worth more than security
  boot.kernelParams = [ "mitigations=off" ];
}
