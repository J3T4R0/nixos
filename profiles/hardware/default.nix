# Options, drivers and more for hardware that I use accross multiple devices
# For now this only includes uhk-agent for my UltimateHackingKeyboard
{ config, lib, pkgs, ... }: {
  services = {
    # i'd like to except the UHK from this, xkbmod seems simpler for now
    # interception-tools = {
    #   enable = true;
    #   plugins = [ pkgs.interception-tools-plugins.caps2esc ];
    #   udevmonConfig = ''
    #     - JOB: intercept -g $DEVNODE | caps2esc | uinput -d $DEVNODE
    #       DEVICE:
    #         EVENTS:
    #           EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
    #   '';
    # };
    udev.packages = with pkgs; [ uhk-agent ];
    ratbagd.enable = true; # my mouse
    fwupd.enable = true;
  };
  environment.systemPackages = with pkgs; [ uhk-agent piper ];
}
