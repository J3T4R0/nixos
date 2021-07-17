{ config, lib, pkgs, modulesPath, externModules, suites, ... }:

{

  imports = suites.base ++ [
    ../profiles/graphical
    ../profiles/graphical/x11Gestures.nix

    ../profiles/virt
    ../profiles/ssh

    ../profiles/hardware
    ../profiles/hardware/tuxedo.nix
    ../profiles/hardware/amd_cpu.nix
    ../profiles/hardware/amd_gpu.nix
  ];

  # some more hardware settings
  nix.maxJobs = lib.mkDefault 16;

        networking.hostName = "itshaydencmp";
        networking.firewall.enable = lib.mkForce true;
        networking.networkmanager.enable = true;
        networking.useDHCP = false;
        networking.interfaces.enp0s31f6.useDHCP = true;
        networking.interfaces.wlp4s0.useDHCP = true;
        boot.cleanTmpDir = true;
        boot.tmpOnTmpfs = true;
        boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
        boot.initrd.kernelModules = [ ];
        boot.kernelModules = [ "kvm-amd" ];
        boot.extraModulePackages = [ ];
        boot.loader.grub.devices = ["/dev/nvme0n1"];
    #    boot.loader.systemd-boot.enable = true;
    #    boot.loader.efi.canTouchEfiVariables = true;
    #    boot.zfs.requestEncryptionCredentials = true;
    #    boot.supportedFilesystems = ["zfs"];
    #    services.zfs.autoSnapshot.enable = true;
    #    services.zfs.autoScrub.enable = true;
        time.timeZone = "US/Pacific";
        networking.hostId = "a3c04b60";


  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

        fileSystems."/" =
          {
          device = "rtank/root/nixos";
          # device = "/dev/disk/by-uuid/nvme-SAMSUNG_MZVLB256HAHQ-000L7_S41GNX0N131513-part4";
          fsType = "zfs";
        };

        fileSystems."/boot" =
          { device = "/dev/disk/by-uuid/F41A-B69B";
          fsType = "vfat";
        };

        fileSystems."/home" =
        {
        device = "rtank/home";
      fsType = "zfs";
        };

        swapDevices = [ { device = "/dev/disk/by-uuid/ce69d716-5608-4e1c-8620-f15e4f71f91c"; } ];
 #   swapDevices =
 #     [ { device = "/dev/disk/by-uuid/92b0b9b7-c797-460c-b6dd-faad7040a2bd"; }
 #   ];
    nix.maxJobs = lib.mkDefault 12;
    i18n.inputMethod.enabled = "ibus";
    i18n.inputMethod.ibus.engines = with pkgs.ibus-engines; [ anthy mozc ];
  }
