{ config, lib, pkgs, ... }:
let
  desktop-overrides = with pkgs;
    mkDerivation rec {
      name = "desktop-overrides";
      phases = [ "installPhase" ];
      installPhase = ''
        mkdir -p $out
        cp ${firefox-wayland}/share/applications/firefox.desktop $out/firefox.desktop
        echo "Actions=private;\n\n[Desktop Action private]\nName=New Private Window\nExec=firefox --private-window %U" >> $out/firefox.desktop
      '';
    };
in {
  xdg.dataFile = {
    apps = {
      recursive = true;
      source = ./apps;
      # source = desktop-overrides;
      target = "applications";
    };
  };
}
