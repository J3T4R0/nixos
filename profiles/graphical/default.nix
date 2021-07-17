{ lib, pkgs, ... }: {
  imports = [
    ./custom-gnome.nix # change some default applications, install extensions
    ./font.nix # change some default applications, install extensions
    # ../hardware # uhk setup
  ];

  hardware = {
    video.hidpi.enable = lib.mkDefault true;
    opengl.enable = true;
    pulseaudio.enable = false;
    #   # Enable AirPlay support
    #   package = pkgs.pulseaudioFull;
    #   zeroconf.discovery.enable = true;
    #   extraConfig = "load-module module-raop-discover";
    # };
  };
  #
  boot = {
    plymouth = {
      enable = true;
      theme = "spinner";
    };

    kernelPackages = pkgs.linuxPackages_latest;
  };

  console = {
    # High-DPI + powerline console font (usable starship promt in tty)
    packages = [ pkgs.powerline-fonts ];
    font = "ter-powerline-v24n";
    # use this font already for boot log and luks password promt
    earlySetup = true;
  };

  # rtkit is optional but recommended see https://nixos.wiki/wiki/PipeWire
  security.rtkit.enable = true;

  services = {
    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;

      media-session.config.bluez-monitor.rules = [
        {
          # Matches all cards
          matches = [ { "device.name" = "~bluez_card.*"; } ];
          actions = {
            "update-props" = {
              "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
              # mSBC is not expected to work on all headset + adapter combinations.
              "bluez5.msbc-support" = true;
            };
          };
        }
        {
          matches = [
            # Matches all sources
            { "node.name" = "~bluez_input.*"; }
            # Matches all outputs
            { "node.name" = "~bluez_output.*"; }
          ];
          actions = {
            "node.pause-on-idle" = false;
          };
        }
      ];
    };

    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      layout = "de+us";
      xkbOptions = "terminate:ctrl_alt_bksp,caps:escape_shifted_capslock";
    };
  };

  # fast shutdown is more important than gracefully shuting down
  systemd.extraConfig = "DefaultTimeoutStopSec=5s";

  environment = {
    # additional packages, not related to gnome
    systemPackages = with pkgs; [ firefox-wayland ];
  };

}
