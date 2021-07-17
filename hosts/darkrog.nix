{ config, lib, pkgs, modulesPath, externModules, hardware, ... }:

{
  # BIOS SETTINGS (Advanced)
  # AMD CBS > CPU COM... > Custom P states > 6 disabled HACK to hopefully fix freezes...
  # CPU Conf > SVM Mode Enable (virtualisation)
  # (Activate stealth mode to get rid of the LEDs)

  imports =
    [
      ../users/benneti
      ../users/camillo
      ../users/root
      ../profiles/graphical
      ../profiles/ssh
      ../profiles/hardware/amd_cpu.nix
      ../profiles/hardware/amd_gpu.nix
    ];

  nix.maxJobs = lib.mkDefault 16;

  # services = {
  #   sshd.enable = true;
  # };

  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
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
      device = "/dev/disk/by-uuid/ce6b1070-80b8-41bb-a57c-bf761911062f";
      fsType = "btrfs";
      options = [ "subvol=@/.snapshots/1/snapshot" ];
    };


    "/home" = {
      device = "/dev/disk/by-uuid/d2b1aeac-a214-471c-8668-4811cbca30ce";
      fsType = "btrfs";
    };



    "/boot" = {
      device = "/dev/disk/by-uuid/C532-A16B";
      fsType = "vfat";
    };

    "/data" = {
      device = "/dev/disk/by-uuid/0f70e10a-c0f5-42ac-a6c7-ced901db6ca4";
      fsType = "btrfs";
    };

  };

  # make more out of the ram
  zramSwap.enable = true;

}
