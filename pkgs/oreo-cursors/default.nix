{ stdenv, srcs, gnome-themes-extra, inkscape, xcursorgen, ruby }:

let
  colors = ''
    # Name = Colour LabelColour ShadowColour ShadowOpacity
    # dracula = #282a36 #bd93f9 #f8f8f2 0.8
    # dracula = #1e1f29 #bd93f9 #f8f8f2 0.8
    # cyan = #8be9fd #f8f8f2 #282a36 0.8
    # green = #50fa7b #f8f8f2 #282a36 0.8
    # orange = #ffb86c #f8f8f2 #282a36 0.8
    # pink = #ff79c6 #f8f8f2 #282a36 0.8
    purple = #bd93f9 #f8f8f2 #282a36 0.8
    red = #ff5555 #f8f8f2 #282a36 0.8
    # yellow = #f1fa8c #f8f8f2 #282a36 0.8
  '';
in stdenv.mkDerivation rec {
  pname = "oreo-cursors";
  inherit (srcs.oreo-cursors) version;

  src = srcs.oreo-cursors;

  postPatch = ''
    patchShebangs .
    substituteInPlace Makefile --replace "sudo" ""
    echo "${colors}" > generator/colours.conf
    cd generator
    ruby convert.rb
    cd ..
  '';

  nativeBuildInputs = [ gnome-themes-extra inkscape xcursorgen ruby ];

  makeFlags = [ "DESTDIR=${placeholder "out"}" "PREFIX=" ];
}
