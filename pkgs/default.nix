final: prev: {
  pop-shell = prev.callPackage ./pop-shell { };
  gnome-shell-clock-override =
    prev.callPackage ./gnome-shell-clock-override { };
  gr = prev.callPackage ./gr { };
  notify-send-sh = prev.callPackage ./notify-send-sh { };
  restream-sh = prev.callPackage ./restream-sh { };
  remy = prev.callPackage ./remy { };
  soundconverter = prev.callPackage ./soundconverter { };
  flyingfox = prev.callPackage ./flyingfox { };
  zsh-vi-mode = prev.callPackage ./zsh-vi-mode { };
  # need manual updates..
  uhk-agent = prev.callPackage ./uhk-agent { };
  schildichat-desktop = prev.callPackage ./schildichat-desktop { };
  # tuxedo-control-center = prev.callPackage ./tuxedo-control-center { };
  tuxedo-touchpad-switch = prev.callPackage ./tuxedo-touchpad-switch { };
  oreo-cursors = prev.callPackage ./oreo-cursors { };
  # adwaita-dracula-cursors = prev.callPackage ./adwaita-dracula-cursors { };
}
