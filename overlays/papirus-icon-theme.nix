# change folder color
# inspired by https://github.com/PapirusDevelopmentTeam/papirus-folders/blob/master/papirus-folders
final: prev: {
  papirus-icon-theme = (prev.papirus-icon-theme.overrideAttrs (old: {
    fixupPhase = ''
      # settings
      color=violet
      THEME_DIR=$out/share/icons/Papirus

      # see change_color
      sizes=(22x22 24x24 32x32 48x48 64x64)
      prefixes=("folder-$color" "user-$color")
      for size in "''${sizes[@]}"; do
        for prefix in "''${prefixes[@]}"; do
          for file_path in "$THEME_DIR/$size/places/$prefix"{-*,}.svg; do
            [ -f "$file_path" ] || continue  # is a file
            [ -L "$file_path" ] && continue  # is not a symlink

            file_name="''${file_path##*/}"
            symlink_path="''${file_path/-$color/}"  # remove color suffix

            ln -sf "$file_name" "$symlink_path" || {
              fatal "Fail to create '$symlink_path' symlink"
            }
          done
        done
      done
    '';
  }));
}
