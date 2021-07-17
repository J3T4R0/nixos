{ options, config, lib, pkgs, home-manager, ... }:
# requires profiles/graphical/gnome/default.nix

# TODO nautilus terminal https://github.com/flozz/nautilus-terminal (see https://nixos.wiki/wiki/Python)
let
  inherit (config.home) homeDirectory;
  inherit (import ./presenter-pointer.nix {
    inherit pkgs;
    inherit config;
  })
    presenter-pointer-desktop;
in {

  imports = [

    # keyboard settings + keybindings for the shell
    ./keyboard.nix

    # shell extensions
    ./extensions.nix

    # theme settings
    ./theme.nix

  ];

  home.packages = [ presenter-pointer-desktop ];

  gtk = {
    enable = true;
    gtk3.bookmarks = [
      "file://${homeDirectory}/repos"
      "file://${homeDirectory}/cloud"
      "file://${homeDirectory}/cloud/Studium/PhD/pdfs/paper"
      "file://${homeDirectory}/cloud/Studium/PhD/pdfs/books"
      "file://${homeDirectory}/cloud/Studium/Master/paper_ma"
    ];
  };

  dconf.settings = with lib.hm.gvariant; {

    "org/gnome/shell".favorite-apps = [
      "org.gnome.Nautilus.desktop"
      "Alacritty.desktop"
      "firefox.desktop"
      "emacs.desktop"
      "schildichat-desktop.desktop"
      "org.gnome.Lollypop.desktop"
    ];

    # TODO think about what I want!
    "org/gnome/mutter".workspaces-only-on-primary = true;

    "org/gnome/desktop/sound".allow-volume-above-100-percent = true;

    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      two-finger-scrolling = true;
    };

    "org/gnome/desktop/applications/terminal" = {
      exec = "alacritty";
      exec-args = "";
    };

    "org/gnome/desktop/screensaver" = { lock-delay = mkUint32 1800; };

    "org/gnome/desktop/interface" = {
      font-name = "Fira Sans 12";
      document-font-name = "Fira Sans 12";
      monospace-font-name = "Fira Code Regular 12";
      show-battery-percentage = true;
    };

  };
}
