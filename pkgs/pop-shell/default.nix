{ stdenv, lib, srcs, nodePackages, glib, substituteAll, gjs }:

stdenv.mkDerivation rec {
  pname = "pop-os-shell";
  inherit (srcs.popShell) version;

  extensionUuid = "pop-shell@system76.com";

  src = srcs.popShell;

  nativeBuildInputs = [ glib nodePackages.typescript gjs ];

  buildInputs = [ gjs ];

  makeFlags = [ "XDG_DATA_HOME=$(out)/share" ];

  preBuild = ''
    find ./ -name "*.ts" -exec sed -i "s|/usr/bin/gjs|/usr/bin/env gjs" {} \;
  '';

  postInstall = ''
    chmod +x $out/share/gnome-shell/extensions/${extensionUuid}/floating_exceptions/main.js
    chmod +x $out/share/gnome-shell/extensions/${extensionUuid}/color_dialog/main.js
  '';

  meta = with lib; {
    description = "Keyboard-driven layer for GNOME Shell";
    license = licenses.gpl3Only;
    homepage = "https://github.com/pop-os/shell";
    platforms = platforms.linux;
    maintainers = with maintainers; [ remunds ];
  };
}
