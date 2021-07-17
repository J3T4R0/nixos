{ config, lib, pkgs, ... }:
let
  ifGui = lib.mkIf config.services.xserver.enable;

  cli-imports = [
    # TODO initial setup of repos automation!
    # ./activation.nix # activation is run on every boot, therefore this is not a good Idea
    # personal settings
    ./app-settings # TODO make aware of pure cli setups
    # settings from user profiles
    ../profiles/git
    ../profiles/xdg
    ../profiles/pass
    ../profiles/beets
    ../profiles/direnv
    ../profiles/julia
    ../profiles/firefox
    ../profiles/borg
  ];
  gui-imports = [
    # gui
    ./mail.nix # TODO make aware of pure cli setups
    ./sync.nix # TODO make aware of pure cli setups
    ./desktop-overrides.nix
    ../profiles/alacritty
    ../profiles/emacs
    ../profiles/gnome-session
  ];
  my-imports = if config.services.xserver.enable then
    cli-imports ++ gui-imports
  else
    cli-imports;

  cli-packages = with pkgs; [
    get_iplayer
    gallery-dl
    youtube-dl
    gocryptfs
    nix-index # command-not-found
    # remarkable
    rmapi
    pdfgrep # grep through pdf files
    pdftk # usefull to edit pdfs colors 0.* 0.* 0.* +(scn|rg)
  ];
  gui-packages = with pkgs; [
    xclip
    wl-clipboard # xclip for wayland
    notify-send-sh
    # remarkable
    remy
    restream-sh
    # Office
    calibre
    libreoffice-fresh
    inkscape
    gimp
    # im
    schildichat-desktop
    element-desktop
    jitsi-meet-electron
    tdesktop
    discord
    zoom-us
    skypeforlinux
    # other
    # TODO use homemanager to install chromium with a minimal set of extensions
    chromium # sometimes firefox doesn't work...
    tor-browser-bundle-bin
    # wine
    # wineWowPackages.staging
    # winetricks
    soundconverter
    picard # musicbrainz audio tagger
  ];
  my-packages = if config.services.xserver.enable then
    cli-packages ++ gui-packages
  else
    cli-packages;
in {
  home-manager.users.benneti = {
    imports = my-imports;

    home.packages = my-packages;

    fonts = { fontconfig.enable = true; };

    systemd.user.services = {

      schildichat = ifGui {
        Service = {
          ExecStartPre = lib.mkForce "${pkgs.coreutils}/bin/sleep 5";
          ExecStart =
            "${pkgs.schildichat-desktop}/bin/schildichat-desktop --hidden";
        };
        Unit = {
          Description = "SchildiChat Desktop";
          After = [ "graphical-session.target" ];
          PartOf = [ ];
        };
        Install = { WantedBy = [ "graphical-session.target" ]; };
      };

    };

  };

  users.users.benneti = {
    uid = 1000;
    hashedPassword =
      "$6$CNe6VpJlsgPEA4JP$juJCylLpwvo.LgbG5j3nzDZJIPZez3T3RvlIIa4CNRnvcCSUDwBHR0o96cO65rNdjf/2oHQTd3Glaz4iiRRPX/";
    description = "Benedikt Tissot";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "input" ];
    shell = pkgs.zsh;
  };

}
