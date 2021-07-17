{ config, lib, pkgs, ... }:
let
  # To move the directory, one also has to change the paths in the settings.library files
  # music_dir = "${config.home.homeDirectory}/Nextcloud/Shared multimedia/Music";
  music_dir = "${config.home.homeDirectory}/music";
in
{
  programs.beets = {
    enable = true;
    settings = {
      directory = music_dir;
      library = "${music_dir}/musiclibrary.db";
      art_filename = "cover";
      plugins = "missing edit fetchart embedart duplicates fuzzy";
      original_date = true;
      group_albums = true;
      "import" = {
        write = true;
        move = true;
        resume = false;
        log =
          if config.xdg.enable
          then "${config.xdg.dataHome}/beets/log.txt"
          else "~/.local/share/beets/log.txt";
      };
      ui.color = true;
      paths = {
        default = "$albumartist/$album/$track $title";
        "albumtype:soundtrack" = "Soundtracks/$album/$track $title";
      };
      fetchart = {
        cautious = true;
        cover_names = "front back";
        sources = "amazon *";
      };
      edit = {
        itemfields = "track title artist artist_sort albumartist albumartist_sort album";
        albumfields = "album albumartist sort_albumartist";
      };
    };
  };
}
