{ stdenv, lib, srcs, makeWrapper, bash, lz4, ffmpeg-full, openssh
, makeDesktopItem, desktop-file-utils }:
let

  desktopItem = makeDesktopItem {
    name = "reStream";
    desktopName = "reStream";
    genericName = "reMarkable Screen Sharing";
    # icon = "tablet";
    icon = "com.github.maoschanz.drawing";
    exec = "restream";
    extraEntries = ''
      StartupWMClass=reStream
      Actions=SSH;

      [Desktop Action SSH]
      Name=Connect via SSH
      Exec=restream -s remarkable
    '';
  };
in stdenv.mkDerivation rec {
  pname = "restream-sh";
  inherit (srcs.restream) version;

  src = srcs.restream;

  dontBuild = true;

  buildInputs = [ desktop-file-utils ];
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -m755 -D reStream.sh "$out/bin/restream"

    wrapProgram "$out/bin/restream" --suffix PATH : ${
      lib.makeBinPath [ ffmpeg-full lz4 bash openssh ]
    }

    ${desktopItem.buildCommand}
  '';

  meta = with lib; {
    description =
      "Stream reMarkable screen using ffplay (ffmpeg-full), lz4 and bash. Needs a ssh connection to the remarkable and the corresponding binary on it.";
    homepage = "https://github.com/rien/reStream";
    maintainers = [ ];
    license = licenses.mit;
    platforms = platforms.linux;
  };

}
