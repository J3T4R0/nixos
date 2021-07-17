{ srcs, stdenv, runtimeShell, config, lib, pkgs, python3 ? pkgs.python38
, pythonPackages ? pkgs.python38Packages, qt5, rsync, openssh
, desktop-file-utils, ... }:
with pythonPackages;
let
  # remy-python = let simplification = buildPythonPackage rec {
  #   pname = "simplification";
  #   version = "0.5.7";

  #   src = fetchPypi {
  #     inherit pname version;
  #     sha256 = "ff08d10cda1d36c68657d6ad20d74fbea493d980f8b2d45344e00d6ed2bf6ed4";
  #   };

  #   propagatedBuildInputs = [
  #     numpy
  #     setuptools
  #   ];

  #   meta = with lib; {
  #     description = "Simplify a LineString using the Ramer–Douglas–Peucker or Visvalingam-Whyatt algorithms";
  #     homepage = "https://github.com/urschrei/simplification";
  #     license = licenses.asl20;
  #     maintainers = with maintainers; [ thoughtpolice ];
  #   };
  # }; in (python3.withPackages (ps: with ps; [ requests arrow paramiko pypdf2 pyqt5 poppler-qt5 simplification ])).override (args: { ignoreCollisions = true; });
  remy-python = (python3.withPackages (ps:
    with ps; [
      requests
      arrow
      paramiko
      pypdf2
      pyqt5
      poppler-qt5
    ])).override (args: { ignoreCollisions = true; });
  # needs desktop-file-utils in build inputs where it is used...
in stdenv.mkDerivation rec {
  pname = "remy";
  inherit (srcs.remy) version;

  src = srcs.remy;

  desktopItem = pkgs.makeDesktopItem {
    name = "remy";
    desktopName = "remy";
    genericName = "reMarkable Sync";
    # icon = "input-tablet";
    icon = "com.remarkable.reMarkable";
    # icon = "paperwork";
    exec = "remy";
    extraEntries = ''
      StartupWMClass=remygui.py
    '';
  };

  propagateBuildInputs = [ remy-python rsync openssh ];

  nativeBuildInputs = [ qt5.wrapQtAppsHook ];
  dontWrapQtApps = true;

  installPhase = ''
    mkdir -p $out/src
    mkdir -p $out/bin

    # comment out problematic line

    # substituteInPlace remy/remarkable/metadata.py \
    #   --replace "self._pdf.setRenderHint(Poppler.Document.HideAnnotations)" "# self._pdf.setRenderHint(Poppler.Document.HideAnnotations)/"

    mv * $out/src

    sed -i "1s|^|#!${remy-python}/bin/python\n|" "$out/src/remygui.py"
    chmod +x "$out/src/remygui.py"

    makeQtWrapper "$out/src/remygui.py" $out/bin/remy \
      --set PYTHONPATH "${remy-python}/lib/python3.8/site-packages" \
      --prefix PATH : ${lib.makeBinPath [ remy-python rsync openssh ]}

    # for developing remy and debugging, als provide the python env
    makeQtWrapper "${remy-python}/bin/python" $out/bin/remy-python \
      --set PYTHONPATH "${remy-python}/lib/python3.8/site-packages" \
      --prefix PATH : ${lib.makeBinPath [ remy-python rsync openssh ]}

    install -D -t $out/share/applications $desktopItem/share/applications/*
  '';

  meta = with lib; {
    description = "reMy, a reMarkable tablet manager app";
    homepage = "https://github.com/bordaigorl/remy";
    maintainers = [ ];
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
