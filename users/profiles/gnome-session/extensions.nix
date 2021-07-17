{ config, lib, pkgs, ... }:

let
  inherit (builtins) listToAttrs;

  # need to be installed system wide!
  extensions = with pkgs.gnomeExtensions; [
    pkgs.pop-shell  # packaged in /pkgs
    pkgs.gnome-shell-clock-override # custom branch not in ego
    espresso
    appindicator-support
    vertical-overview
    user-themes
  ];
  systemExtensions = [
    "gsconnect@andyholmes.github.io"
  ];

  uuid = e:
    if e ? extensionUuid
    then e.extensionUuid
    else e.uuid;

in
{
  # home.packages = extensions;

  xdg.dataFile = listToAttrs
    (map
      (e:
        let target = "gnome-shell/extensions/${(uuid e)}"; in
        {
          name = target;
          value = {
            # recursive = true;
            recursive = false; # hopefully makes it impossible for gnome to update my extensions
            source = "${e}/share/${target}";
          };
        })
      extensions);

  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/shell" = {
      disable-user-extensions = false;

      enabled-extensions = (map uuid extensions)
        ++ systemExtensions;
    };



    "org/gnome/shell/extensions/user-theme" = { name = "Dracula"; };

    "org/gnome/shell/extensions/clock_override".override-string =
      "%A %F  %H:%M";

    "org/gnome/shell/extensions/pop-shell" = {
      active-hint = true;
      gap-inner = mkUint32 0;
      gap-outer = mkUint32 0;
      hint-color-rgba = "rgb(189,147,249)";
      # show-title = false; # FIXME does this fix x11 login after nrs?
      smart-gaps = false;
      snap-to-grid = true;
      tile-by-default = true;
    };

    # "org/gnome/shell/extensions/hidetopbar" = {
    #   enable-active-window = false;
    #   enable-intellihide = true;
    #   hot-corner = true;
    #   mouse-sensitive = true;
    #   mouse-sensitive-fullscreen-window = false;
    # };

    "org/gnome/shell/extensions/espresso" = {
      enable-fullscreen = false;
      show-notifications = false;
      user-enabled = true;
    };

    "org/gnome/shell/extensions/dash-to-panel" = {
      animate-app-switch = true;
      animate-window-launch = true;
      click-action = "CYCLE";
      dot-style-focused = "SEGMENTED";
      dot-style-unfocused = "DOTS";
      group-apps = true;
      hotkeys-overlay-combo = "TEMPORARILY";
      intellihide = true;
      intellihide-animation-time = 100;
      intellihide-behaviour = "ALL_WINDOWS";
      intellihide-close-delay = 200;
      intellihide-hide-from-windows = true;
      # intellihide-key-toggle = "@as []";
      intellihide-pressure-threshold = 200;
      intellihide-use-pressure = true;
      multi-monitors = false;
      panel-element-positions = ''
        {"0":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":false,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"centerBox","visible":false,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":false,"position":"stackedBR"}],"1":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":false,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"centerBox","visible":false,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":false,"position":"stackedBR"}]}'';
      panel-positions = ''{"0":"BOTTOM","1":"BOTTOM"}'';
      panel-size = 48;
      primary-monitor = 0;
      scroll-icon-action = "PASS_THROUGH";
      show-appmenu = false;
      show-tooltip = false;
      show-window-previews = true;
      stockgs-panelbtn-click-only = false;
    };

  };

}
