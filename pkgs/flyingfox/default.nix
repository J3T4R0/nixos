{ lib, stdenv, srcs }:
let inherit (srcs) FlyingFox;
in stdenv.mkDerivation rec {
  pname = "FlyingFox";
  inherit (FlyingFox) version;

  src = srcs.FlyingFox;

  nativeBuildInputs = [ ];

  installPhase = ''
    mkdir -p $out
    mv user.js $out/
    mv chrome $out/
    mv $out/chrome/config.css $out/chrome/config_example.css
  '';
}
