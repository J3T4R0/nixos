{ config, lib, pkgs, modulesPath, externModules, suites, ... }:

{

  imports = suites.base ++ [
    ../profiles/graphical

    # ../profiles/virt
    ../profiles/ssh

    ../profiles/hardware
    ../profiles/hardware/intel.nix
    ../profiles/hardware/amd_gpu.nix
  ];

  # some more hardware settings
  nix.maxJobs = lib.mkDefault 4;

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sr_mod" "btrfs" ];
      kernelModules = [ "usbhid" ];
    };

    tmpOnTmpfs = true;

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

  };

  # disk setup -- mount points
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/1e689468-4855-45fd-91da-444cdca1a841";
      fsType = "ext4";
    };

    "/home" = {
      device = "/dev/disk/by-uuid/e49aa700-ce1e-4911-9ad8-9340e5e577f0";
      fsType = "btrfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/3AB5-6203";
      fsType = "vfat";
    };
  };

  swapDevices = [ ];

  # make more out of the ram
  zramSwap.enable = true;

}
