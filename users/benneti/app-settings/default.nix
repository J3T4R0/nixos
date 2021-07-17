{ config, lib, pkgs, ... }:
let
  shellAliases = {
    # simple chain of commands to update everything
    up = "nru && nrs; doom up";
  };
  inherit (config.home) homeDirectory;
  inherit (config.xdg) userDirs;
in {
  # some things rely on being able to set user config files
  # system zsh configuration is still valid
  # Additionally disables asking first run wizard
  # and sets up home-manager session variables...
  programs = {
    git = {
      userEmail = "benedikt@tissot.de";
      userName = "Benedikt Tissot";
    };

    zsh = {
      enable = true;
      inherit shellAliases;
      initExtra = ''
        source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh

        # framebuffer / tty dracula colors
        if [ "$TERM" = "linux" ]; then
          echo -en "\e]P0282a36" #background (black)
          echo -en "\e]P844475a" #darkgrey
          echo -en "\e]P1ff5555" #darkred
          echo -en "\e]P9ff6e67" #red
          echo -en "\e]P287AF5F" #darkgreen
          echo -en "\e]PA50fa7b" #green
          echo -en "\e]P3ffb86c" #orange (brown)
          echo -en "\e]PBf1fa8c" #yellow
          echo -en "\e]P4bd93f9" #darkblue
          echo -en "\e]PCcaa9fa" #blue
          echo -en "\e]P5ff79c6" #darkmagenta
          echo -en "\e]PDff92d0" #magenta
          echo -en "\e]P68be9fd" #darkcyan
          echo -en "\e]PE9aedfe" #cyan
          echo -en "\e]P76272a4" #lightgrey
          echo -en "\e]PFf8f8f2" #foreground (white)
          clear #for background artifacting
        fi
      '';
      history.size = 100000;
      dirHashes = {
        nixos = "/etc/nixos";
        docs = "${userDirs.documents}";
        dl = "${userDirs.download}";
        music = "${userDirs.music}";
        vids = "${userDirs.videos}";
        pics = "${userDirs.pictures}";
        repos = "${homeDirectory}/repos";
        org = "${homeDirectory}/org";
        cloud = "${homeDirectory}/cloud";
        stud = "${homeDirectory}/cloud/Studium";
        bhlc = "${homeDirectory}/repos/BHLimitCycles";
        phdn = "${homeDirectory}/repos/TMDefectsInSiC";
        phdp = "${homeDirectory}/repos/PhD-presentations";
        phd = "${homeDirectory}/cloud/Studium/PhD";
        paper = "${homeDirectory}/cloud/Studium/PhD/pdfs/paper";
        books = "${homeDirectory}/cloud/Studium/PhD/pdfs/books";
        qm2 = "${homeDirectory}/cloud/Studium/PhD/QM2";
      };
    };
  };

  xdg.configFile = {
    "remy.json".source = ./config/remy.json;
    "ripgrep".source = ./config/ripgrep;
    "SchildiChat/config.json".source = ./config/schildichat.json;
    "Element/config.json".source = ./config/schildichat.json;
  };

  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/Lollypop" = {
      artist-artwork = true;
      import-advanced-artist-tags = true;
      music-uris = if config.xdg.userDirs.enable then
        [ "file://${userDirs.music}" ]
      else
        [ "~/.local/share/beets/log.txt" ];
      network-access = true;
      network-access-acl = 1048574;
      notification-flag = 2;
      volume-rate = 1.0;
      window-maximized = false;
      window-position = [ 0 0 ];
      window-size = [ 3840 2160 ];
    };
  };

}
