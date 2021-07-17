{ stdenv, lib, srcs, makeWrapper, bc, glib, bash }:
stdenv.mkDerivation rec {
  pname = "notify-send-sh";
  inherit (srcs.notifySendSH) version;

  src = srcs.notifySendSH;

  dontBuild = true;

  buildInputs = [ makeWrapper ];

  installPhase = ''
    install -m755 -D notify-send.sh "$out/bin/notify-send.sh"
    install -m755 -D notify-action.sh "$out/bin/notify-action.sh"
    for p in $out/bin/*; do
      wrapProgram "$p" --suffix PATH : ${lib.makeBinPath [ glib bc bash ]}
    done
  '';

  meta = with lib; {
    description =
      "Desktop notifications using bash, glib, and bc. (Linux only)";
    homepage = "https://github.com/vlevit/notify-send.sh";
    maintainers = [ ];
    license = licenses.gpl3;
    platforms = platforms.linux;
  };

}
