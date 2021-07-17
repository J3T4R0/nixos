{ config, lib, pkgs, ... }:
let
  left = "h";
  down = "j";
  up = "k";
  right = "l";
  inherit (import ./presenter-pointer.nix {
    inherit pkgs;
    inherit config;
  })
    presenter-pointer;
  toggleVpn = pkgs.writeShellScriptBin "toggleVpn" ''
      export PATH="$PATH:${lib.makeBinPath (with pkgs; [ networkmanager gawk gnugrep ])}";

      vpn=$(nmcli connection show | awk '/vpn/ {print $1}')
      vpn=''${vpn:-'unikn'}

      if nmcli connection show --active | grep "$vpn" > /dev/null; then
        nmcli connection down "$vpn"
      else
        nmcli connection up "$vpn"
      fi
    '';
in {
  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/desktop/input-sources" = {
      xkb-options =
        [ "terminate:ctrl_alt_bksp" "caps:escape_shifted_capslock" ];
      sources = [ (mkTuple [ "xkb" "de+us" ]) ];
    };

    # key bindings for pop-shell
    # https://github.com/pop-os/shell/blob/master/schemas/org.gnome.shell.extensions.pop-shell.gschema.xml
    "org/gnome/shell/extensions/pop-shell".activate-launcher =
      [ "<Super>space" ];

    "org/gnome/mutter/wayland/keybindings" = { restore-shortcuts = [ ]; };
    "org/gnome/shell/keybindings" = {
      open-application-menu = [ ];
      toggle-message-tray = [ "<Super>n" ];
    };

    "org/gnome/desktop/wm/preferences" = {
      titlebar-font = "Fira Sans Bold 12";
      button-layout = "";
      mouse-button-modifier = "<Super>";
    };

    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>q" ];
      minimize = [ "<Super>comma" ];
      maximize = [ ];
      toggle-maximized = [ "<Super>m" ];
      toggle-fullscreen = [ "<Super>f" ];
      toggle-on-all-workspaces = [ "<Super>p" ];
      activate-window-menu = [ "" ];

      switch-to-workspace-left = [ ];
      switch-to-workspace-right = [ ];
      switch-to-workspace-down =
        [ "<Primary><Super>Down" "<Primary><Super>${down}" ];
      switch-to-workspace-up =
        [ "<Primary><Super>Down" "<Primary><Super>${up}" ];

      move-to-workspace-down = [ "<Shift><Super>Down" "<Shift><Super>${down}" ];
      move-to-workspace-up = [ "<Shift><Super>Up" "<Shift><Super>${up}" ];
      move-to-monitor-left = [ "<Shift><Super>Left" "<Shift><Super>${left}" ];
      move-to-monitor-right =
        [ "<Shift><Super>Right" "<Shift><Super>${right}" ];
      move-to-monitor-up = [ "" ];
      move-to-monitor-down = [ "" ];

      switch-input-source = [ ];
      switch-input-source-backward = [ ];
    };

    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = [ ];
      toggle-tiled-right = [ ];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      screensaver = [ "<Super>Delete" ]; # lock screen
      home = [ "<Super>slash" ];
      email = [ ];
      www = [ "<Super>b" ];
      rotate-video-lock-static = [ ];
      # keybingings need to have the folder customN
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" =
      {
        binding = "<Super>t";
        command = "alacritty";
        name = "Terminal";
      };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" =
      {
        binding = "<Super>e";
        command = "emacs";
        name = "Emacs";
      };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" =
      {
        binding = "<Shift><Super>space";
        command = "emacs";
        name = "Emacs";
      };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" =
      {
        binding = "<Super>c";
        command = "schildichat-desktop";
        name = "SchildiChat";
      };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" =
      {
        binding = "<Super>p";
        command = "${presenter-pointer}/bin/presenter-pointer";
        name = "presenter-pointer";
      };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5" =
      {
        binding = "<Super>v";
        command = "${toggleVpn}/bin/toggleVpn";
        name = "toggle VPN";
      };

  };
}
