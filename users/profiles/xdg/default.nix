{ config, pkgs, lib, ... }:
let
  xdgConfig = config.xdg.configHome;
  xdgData = config.xdg.dataHome;
  xdgCache = config.xdg.cacheHome;

  inherit (config.home) homeDirectory;

  shellAliases = {
    # hard fixes
    wget = "${pkgs.wget}/bin/wget --hsts-file ${xdgCache}/wget-hsts";
    # commodity alias
    open = "${pkgs.xdg_utils}/bin/xdg-open";
  };

  # TODO gdg (.gnupg)
  # TODO firefox (.mozilla)
  # TODO mbsync (.mbsync .mbsyncrc)
  # TODO julia (.julia)
  # TODO ipython (.ipython)
  # TODO jupyter (.jupyter)
  # TODO (.esd_auth)
  # TODO (.compose-cache)
  # TODO bash (.bash_history) # if it is not

in
{
  xdg = {
    enable = true;

    # TODO consider this setup
    # cacheHome = "${homeDirectory}/.local/cache/";
    # configHome = "${homeDirectory}/.local/config/";

    userDirs = {
      enable = true;

      # home folder structure
      documents = "${homeDirectory}/documents";
      download = "${homeDirectory}/downloads";
      music = "${homeDirectory}/music";
      videos = "${homeDirectory}/videos";
      pictures = "${homeDirectory}/pictures";
      publicShare = "${homeDirectory}/share";
      extraConfig = {
        XDG_REPOS_DIR = "${homeDirectory}/repos";
        XDG_MAIL_DIR = "${homeDirectory}/mail";
        XDG_PAPER_DIR = "${homeDirectory}/cloud/Studium/PhD/pdfs/paper";
        XDG_CLOUD_DIR = "${homeDirectory}/cloud";
      };

      # hide mostly unused folders in xdg.dataHome
      templates = "${xdgData}/templates";
      desktop = "${xdgData}/desktop";
    };

    # TODO configure mimeapps
    mimeApps = {
      # enable = true;
      defaultApplications = {
        "application/pdf" = "${pkgs.evince}/share/applications/org.gnome.Evince.desktop";
      };
    };
  };

  home.sessionVariables = {
    GETIPLAYERUSERPREFS = "${xdgData}/get_iplayer";
    LESSKEY = "${xdgConfig}/less/lesskey";
    LESSHISTFILE = "${xdgConfig}/less/history";
    XCOMPOSECACHE = "${xdgCache}/X11/xcompose";
    # GNUPGHOME="${xdgData}/gnupg";
  };

  programs =
    let
    in {
    zsh = {
      # home manager actually prefixes this with $HOME
      # history.path = "${xdgData}/zsh/history";
      history.path = ".local/share/zsh/history";
      dotDir = ".config/zsh";
      inherit shellAliases;
    };
    bash = {
      historyFile = ".local/share/bash/history";
      inherit shellAliases;
    };

  };

}
