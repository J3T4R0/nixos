{ lib
, stdenv
, srcs
, cmake
, udev
, glib
, pkg-config
, makeWrapper
}:
stdenv.mkDerivation rec {
  pname = "tuxedo-touchpad-switch";
  version = "flake";

  src = srcs.tuxedo-touchpad-switch;

  nativeBuildInputs = [ cmake udev glib pkg-config makeWrapper ];

  preConfigure = ''
    substituteInPlace CMakeLists.txt \
      --replace "include(MunkeiVersionFromGit.cmake)" "" \
      --replace "version_from_git(TIMESTAMP \"%Y%m%d%H%M%S\")" "set( PKG_CONFIG_EXECUTABLE  )" \
      --replace "/usr" "" \
      --replace "DESTINATION " "DESTINATION $out/"
  '';
  postInstall = ''
    wrapProgram $out/bin/${pname} --prefix PATH : ${lib.makeBinPath [ glib ]}
  '';
}
