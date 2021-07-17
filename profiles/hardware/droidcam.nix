{ config, lib, pkgs, ... }:
let
  droidcam_sound = pkgs.writeShellScriptBin "droidcam_sound" ''
    set -euo pipefail
    ${pkgs.droidcam}/bin/droidcam &
    sleep 30
    pacmd load-module module-alsa-source device=hw:2,1,0 source_properties=device.description=droidcam
    wait
  '';

  droidcamDesktopItem = pkgs.makeDesktopItem {
    name = "droidcam";
    desktopName = "droidcam";
    genericName = "Webcam";
    icon = "camera-video";
    exec = "${droidcam_sound}/bin/droidcam_sound";
    extraEntries = ''
      StartupWMClass=Droidcam
    '';
  };

in {
  environment.systemPackages = with pkgs; [ droidcam droidcamDesktopItem ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  boot.kernelModules = [ "v4l2loopback" "snd_aloop" ];
  boot.extraModprobeConfig = ''
    options snd_aloop index=2
  '';
  # for audio run after connecting: pacmd load-module module-alsa-source device=hw:Loopback,1,0
}

