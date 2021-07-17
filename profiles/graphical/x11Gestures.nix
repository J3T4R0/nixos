{ config, lib, pkgs, ... }:
let
  gesturesIfX11 = with pkgs; writeShellScriptBin "gesturesIfX11" ''
    sessiontype="$(loginctl show-session $(awk '/tty/ {print $1}' <(loginctl)) -p Type | awk -F= '{print $2}')"
    if [ "$sessiontype" == "x11" ]; then
      echo "Running on X11: Starting libinput-gestures"
      libinput-gestures
    else
      echo "Not running on X11: Not starting libinput-gestures"
    fi
  '';
in
{

  # user needs to be in the input group
  systemd.user.services.libinput-gestures = {
    description = "Start libinput-gestures in x11";
    after = [ "graphical-session.target" ];
    partOf = [ ];
    path = with pkgs; [ systemd libinput-gestures gawk ];
    script = "${gesturesIfX11}/bin/gesturesIfX11";
    preStart = "${pkgs.coreutils}/bin/sleep 5";
    wantedBy = [ "graphical-session.target" ];
  };

}
