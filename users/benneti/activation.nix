{ config, lib, pkgs, ... }:
let
  xdgConfig = config.xdg.configHome;
  xdgData = config.xdg.dataHome;
  xdgCache = config.xdg.cacheHome;

  inherit (config.home) homeDirectory;
in {
  home.activation = {
    # we do some not strictly necessary stuff here to not depend on ssh keys
    # NOTE test with: flk home darkrog benneti switch --dry-run
    doom = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      doomdir="${xdgConfig}/doom"
      # $VERBOSE_ARG
      if [ -d "$doomdir" ]; then
        $DRY_RUN_CMD git -C "$doomdir" pull http master
      else
        # git clone and change url
        http="https://cloud.tissot.de/gitea/benneti/doom.git"
        $DRY_RUN_CMD git clone "$http" "$doomdir"
        # the new url needs ssh keys setup
        $DRY_RUN_CMD git -C "$doomdir" remote add http "$http"
        $DRY_RUN_CMD git -C "$doomdir" remote set-url origin "gitea@cloud.tissot.de:benneti/doom.git"
      fi
      emacsdir="${xdgConfig}/emacs"
      if [ -d "$emacsdir" ]; then
        if [ -d "$emacsdir/.local" ]; then
          $DRY_RUN_CMD $emacsdir/bin/doom sync
        fi
      else
        $DRY_RUN_CMD git clone --depth 1 https://github.com/hlissner/doom-emacs "$emacsdir"
      fi
    '';

    # folders = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    #   function ln-new() {
    #     source="$1"
    #     target="$2"
    #     if [ -e $target ]; then
    #       if [ -n $VERBOSE_ARG ]; then
    #         echo $target already exists
    #       fi
    #     else
    #       ln -s $VERBOSE_ARG "$source" "$target"
    #     fi
    #   }
    #   $DRY_RUN_CMD ln-new "$HOME/cloud/org" "$HOME/org" || true
    #   $DRY_RUN_CMD ln-new "$HOME/cloud/Pictures" "$HOME/pictures"
    #   $DRY_RUN_CMD ln-new "$HOME/cloud/Documents" "$HOME/documents"
    #   $DRY_RUN_CMD ln-new "$HOME/cloud/Shared multimedia/Music" "$HOME/music"
    #   $DRY_RUN_CMD ln-new "$HOME/cloud/org" "$HOME/org"
    #   $DRY_RUN_CMD mkdir -p "$HOME/videos" $VERBOSE_ARG
    # '';
  };
}
