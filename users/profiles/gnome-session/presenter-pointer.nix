{ config, pkgs, ... }: rec {
  presenter-pointer = with pkgs;
    writeShellScriptBin "presenter-pointer" ''
      set -euo pipefail
      export PATH="$PATH:${lib.makeBinPath [ dconf ]}";

      if [ $# -gt 0 ] || [ $(dconf read /org/gnome/desktop/interface/cursor-theme) = "'oreo_red_cursors'" ] ; then
          dconf reset /org/gnome/desktop/interface/cursor-size
          dconf write /org/gnome/desktop/interface/cursor-theme "'${
            config.dconf.settings."org/gnome/desktop/interface".cursor-theme
          }'"
      else
          dconf write /org/gnome/desktop/interface/cursor-size 96
          dconf write /org/gnome/desktop/interface/cursor-theme "'oreo_red_cursors'"
      fi
    '';
  presenter-pointer-desktop = pkgs.makeDesktopItem rec {
    name = "presenter-pointer";
    desktopName = "Presenter Pointer";
    genericName = desktopName;
    icon = "compiz";
    exec = "${presenter-pointer}/bin/${name}";
    extraEntries = ''
      Actions=RESET;

      [Desktop Action RESET]
      Name=Reset Cursor
      Exec=${presenter-pointer}/bin/${name} 1
    '';
  };
}
