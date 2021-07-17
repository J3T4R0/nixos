{ lib, pkgs, srcs, python3, gobject-introspection, desktop-file-utils, gst_all_1
, gtk3, wrapGAppsHook, intltool, libnotify, ... }:
python3.pkgs.buildPythonApplication rec {
  pname = "soundconverter";
  inherit (srcs.soundconverter) version;

  format = "other";
  doCheck = false;

  src = srcs.soundconverter;

  nativeBuildInputs =
    [ desktop-file-utils gobject-introspection wrapGAppsHook intltool ];

  buildInputs = with gst_all_1; [
    gst-libav
    gst-plugins-bad
    gst-plugins-base
    gst-plugins-good
    gst-plugins-ugly
    gstreamer
    gtk3
    libnotify
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pygobject3
    pycairo
    distutils_extra
    setuptools
  ];

  strictDeps = false;

  # Arguments to be passed to `makeWrapper`, only used by buildPython*
  dontWrapGApps = true;
  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  postFixup = ''
    wrapPythonProgramsIn $out/bin "$out $propagatedBuildInputs"
  '';

  installPhase = ''
    ${python3.interpreter} setup.py install --prefix=$out
    mv data $out/lib/${python3.libPrefix}/site-packages/
  '';

  meta = with lib; {
    description = "soundconverter for gnome";
    homepage = "https://soundconverter.org/";
    maintainers = [ ];
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
