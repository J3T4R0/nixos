{ stdenv, srcs, nodePackages, glib, substituteAll, gjs, zip, unzip }:

let inherit (srcs) gnomeShellClock;
in stdenv.mkDerivation rec {
  pname = "gnome-shell-clock-override";
  inherit (gnomeShellClock) version;

  src = gnomeShellClock;

  extensionUuid = "clock-override@gnomeshell.kryogenix.org";

  nativeBuildInputs = [ glib gjs zip unzip ];

  preBuild = ''
    sed -i "s|\$(HOME)/.local|$out|" Makefile
  '';

  buildInputs = [ gjs ];
}
