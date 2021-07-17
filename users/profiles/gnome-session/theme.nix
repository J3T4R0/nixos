{ config, lib, pkgs, ... }: {

  gtk = {
    enable = lib.mkDefault true;
    theme = {
      name = "Dracula";
      package = pkgs.dracula-theme;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };
  home.packages = with pkgs; [
    libsForQt5.qtstyleplugin-kvantum
    oreo-cursors
    # adwaita-dracula-cursors
  ];

  home.sessionVariables.QT_STYLE_OVERRIDE = "kvantum";
  systemd.user.sessionVariables.QT_STYLE_OVERRIDE = "kvantum";

  # the default has a lot of transparency which does not fit very well with gnome
  # therefore use Dracula-Solid
  xdg.configFile = {
    "kvantum.kvconfig" = {
      text = "theme=Dracula-purple-solid";
      target = "Kvantum/kvantum.kvconfig";
    };
    "Dracula-kvantum" = {
      recursive = true;
      source =
        "${pkgs.dracula-theme}/share/themes/Dracula/kde/kvantum/Dracula-purple-solid";
      target = "Kvantum/Dracula-purple-solid";
    };
  };

  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/desktop/interface".cursor-theme = "Adwaita";
    # "org/gnome/desktop/interface".cursor-theme = "oreo_purple_cursors";

    "org/gnome/settings-daemon/plugins/xsettings" = {
      antialiasing = "rgba";
      hinting = "slight";
    };

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file://" + ./wallpaper-emacs.png;
    };
  };

}
