{ config, lib, pkgs, ... }: {

  hardware.cpu.intel.updateMicrocode = true;

  boot = {
    kernelModules = [ "kvm-intel" ];
    # HACK private PC, so performance is worth more than security
    kernelParams = [ "mitigations=off" ];
  };

}
