{ config, lib, pkgs, modulesPath, externModules, suites, ... }:

{
  imports = [
    ../profiles/core
    ../users/root
    ../profiles/graphical
    ../profiles/ssh
  ];

  # console = {
  #   # High-DPI + powerline console font (usable starship promt in tty)
  #   packages = [ pkgs.powerline-fonts ];
  #   font = "ter-powerline-v24n";
  #   # use this font already for boot log and luks password promt
  #   earlySetup = true;
  # };

  # HACK problems with zfs and the latest kernel
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages;

  networking.networkmanager.enable = true;

  fileSystems."/" = { device = "/dev/disk/by-label/nixos"; };

  home-manager.users.nixos = {
    imports = [
      ../users/profiles/git
      ../users/profiles/direnv
      ../users/profiles/alacritty
      ../users/profiles/gnome-session
    ];

    home.packages = with pkgs; [
      gocryptfs
      nix-index
    ];

    # fonts = { fontconfig.enable = true; };

    programs = {
      git = {
        userEmail = "benedikt@tissot.de";
        userName = "Benedikt Tissot";
      };
    };
  };

  services.xserver = {
    enable = lib.mkForce true;
    displayManager.gdm = {
      enable = lib.mkForce true;
      autoSuspend = false;
    };
    displayManager.autoLogin = {
      enable = true;
      user = "nixos";
    };
    desktopManager.gnome = {
      enable = lib.mkForce true;
      favoriteAppsOverride = ''
        [org.gnome.shell]
        favorite-apps=[ 'Alacritty.desktop',  'org.gnome.Nautilus.desktop', 'firefox.desktop' ]
      '';
    };
    layout = "de+us";
    xkbOptions = "terminate:ctrl_alt_bksp,caps:escape_shifted_capslock";
  };

  users.users.nixos = {
    uid = 1003;
    password = "nixos";
    description = "nixos installer user";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "input" ];
  };

  # from installation-cd-graphical-base.nix
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';


}
