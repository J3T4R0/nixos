{ stdenv, srcs, gnome-themes-extra, inkscape, xcursorgen, python3, python2 }:

let
  # sizes = "24 30 36 42 48 54 60 66 72 78 84 90 96";
  sizes = "24 36 48 96";
  # Name FillColor LineColor
  colors = ''
    dracula #1e1f29 #f8f8f2
    dracula-alt #282a36 #f8f8f2
    white #f8f8f2 #1e1f29
    cyan #8be9fd #282a36
    green #50fa7b #282a36
    orange #ffb86c #282a36
    pink #ff79c6 #282a36
    purple #bd93f9 #282a36
    red #ff5555 #282a36
    yellow #f1fa8c #282a36
  '';
in stdenv.mkDerivation rec {
  pname = "adwaita-dracula-cursors";
  inherit (srcs.adwaita-cursors) version;

  src = srcs.adwaita-cursors;

  nativeBuildInputs =
    [ gnome-themes-extra inkscape xcursorgen python3 python2 ];

  postPatch = ''
    patchShebangs .
    mkdir -p $out/bin
    sed "s/color\[i\] < self.desired\[i\]/color[i] > self.desired[i]/g" colorize.py > colorize_darken.py
    {
        local IFS=$'\n'
        colors="${colors}"
        colors=($colors)
        for col in "''${colors[@]}"; do
            local IFS=" "
            col=($col)
            name="''${col[0]}"
            pri="''${col[1]}"
            sec="''${col[2]}"
            # lighten only works for colors, for the two dracula themes we instead darkendarken not lighten
            if echo $name | grep "dracula"; then
                python3 colorize_darken.py "$pri" > "$name.svg"
                sed -i "s/#000000/$pri/g" "$name.svg"
            else
                python3 colorize.py "$pri" > "$name.svg"
            fi
            sed -i "s/#ffffff/$sec/g" "$name.svg"
        done
    }
    rm adwaita*.svg
  '';

  dontBuild = true;

  installPhase = ''
    for color in *.svg; do
        echo $color
        name="Adwaita-$(basename -s ".svg" $color)"
        echo $name
        mkdir -p "$out/share/icons/$name/"
        mv -f $color adwaita.svg
        SIZES="${sizes}" make
        mv Adwaita/cursors "$out/share/icons/$name/"
        for theme in Adwaita/*.theme; do
            sed "s/Adwaita/$name/g" $theme > "$out/share/icons/$name/$(basename $theme)"
        done
        make distclean
    done
  '';
}
