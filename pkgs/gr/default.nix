{ stdenv, srcs, lib, qt5, libGL, xorg }:

let
  mainDependencies = [
    qt5.qtbase
    qt5.qtsvg
    stdenv.cc.cc.lib
    libGL
    xorg.libXt
    xorg.libX11
    xorg.libXrender
    xorg.libXext
  ];

  inherit (srcs) gr;
in
stdenv.mkDerivation {
  name = "GR";
  version = "latest";

  src = gr;

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ qt5.wrapQtAppsHook ];

  installPhase = ''
    mkdir -p $out
    cp -r ./* $out
  '';

  preFixup =
    let
      libPath = lib.makeLibraryPath (mainDependencies ++ [
        xorg.libxcb
      ]);
    in
    ''
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "${libPath}" \
        $out/bin/gksqt
    '';

  propagatedBuildInputs = mainDependencies ++ [
    xorg.libxcb
    xorg.xcbproto
    xorg.xcbutil
  ];
}
