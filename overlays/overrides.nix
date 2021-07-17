channels: final: prev: {

  __dontExport = true; # overrides clutter up actual creations

  inherit (channels.latest)
    # tools that need to be as up to date as possible
    get_iplayer gallery-dl youtube-dl rmapi
    # messenger
    element-desktop discord zoom-us
    # devos does these
    cachix
    dhall
    manix
    rage
    nixpkgs-fmt
    starship;
}
