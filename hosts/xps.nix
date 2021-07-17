{ config, lib, pkgs, modulesPath, externModules, suites, nixos-hardware, ... }:
# TODO sometimes wifi breaks after sleep,
# consider disabling wifi before sleep and enalbling after
# sudo rmmod ath10k_pci ath10k_core;
# sudo modprobe ath10k_pci ath10k_core;
{

  imports = suites.base ++ [
    ../profiles/graphical
    ../profiles/graphical/x11Gestures.nix

    ../profiles/hardware
    ../profiles/hardware/intel.nix
    ../profiles/hardware/intel_gpu.nix

    ../users/leonie
  ];

  # some more hardware settings
  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  # disable some stuff from nixos-hardware
  services = {
    tlp.enable = false;
    throttled.enable = false;
  };

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
      kernelModules = [ "dm-snapshot" "usbhid" ];
    };

    kernelModules = [ "ath10k_pci" ];

    plymouth = {
      enable = true;
      theme = "spinner";
    };

    tmpOnTmpfs = true;

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # disk setup -- encryption
    initrd.luks.devices."root".device =
      "/dev/disk/by-uuid/5d149e37-356c-4556-a00f-5629209bf994";
    initrd.luks.devices."root".preLVM = true;
  };

  # disk setup -- mount points
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/8bc6314a-782c-465d-a17c-cbb023d418c0";
      fsType = "ext4";
    };

    "/home" = {
      device = "/dev/disk/by-uuid/ec6d03a0-df3f-4d4d-b2be-1c443e52bdab";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/7010-A10F";
      fsType = "vfat";
    };
  };

  # make more out of the ram
  zramSwap.enable = true;

  # swap to be able to hibernate to disk
  swapDevices = [ ];

}
