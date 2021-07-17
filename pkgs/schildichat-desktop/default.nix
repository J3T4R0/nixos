{ lib
, stdenv
, pkgs
, fetchurl
, fetchFromGitHub
, wrapGAppsHook
, glib
, gtk3
, atomEnv
, libdrm
, sqlcipher
, mesa
, nodePackages
, libappindicator
, libxkbcommon
, xorg
}:
let
  debsqlcipher = sqlcipher;
  # debsqlcipher = sqlcipher.overrideAttrs (self: rec {
  #   # we use the debian package for schildichat so maybe we also need the same version of sqlcipher
  #   # https://packages.debian.org/stretch/amd64/libsqlcipher-dev/download
  #   version = "3.4.2";
  #   src = fetchFromGitHub {
  #     owner = "sqlcipher";
  #     repo = "sqlcipher";
  #     rev = "v${version}";
  #     sha256 = "sha256-KthNZKh8lsg7T333BnCElZOWC+1jOYMk8ucqv51ZHJk=";
  #   };
  # });
in
stdenv.mkDerivation rec {
  pname = "schildichat-desktop";
  version = "1.7.29-sc1";

  src = fetchurl {
    url =
      "https://github.com/SchildiChat/${pname}/releases/download/v${version}/${pname}_${version}_amd64.deb";
    sha256 = "sha256-5qhcM4AGOBdDCcqtTKiocA10ldtbcNUZ7t/AG4O3mIc=";
  };

  nativeBuildInputs = [
    wrapGAppsHook # Fix error: GLib-GIO-ERROR **: No GSettings schemas are installed on the system
  ];

  buildInputs = [
    gtk3 # Fix error: GLib-GIO-ERROR **: Settings schema 'org.gtk.Settings.FileChooser' is not installed
    xorg.libxshmfence
  ];

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = ''
    ar p $src data.tar.xz | tar xJ ./usr/ ./opt/
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin/"
    mv usr/share $out
    mv opt/SchildiChat "$out/share/${pname}"
    ln -sf "$out/share/${pname}/${pname}" "$out/bin/${pname}"
    chmod +x "$out/share/${pname}/chrome-sandbox"

    runHook postInstall
  '';

  preFixup = ''
    share=$out/share/${pname}
    libpath="$share:${atomEnv.libPath}:${
      lib.makeLibraryPath [
        libdrm
        mesa
        debsqlcipher
        libappindicator
        libxkbcommon
        xorg.libxshmfence
      ]
    }"
    gappsWrapperArgs+=(
      # needed for gio executable to be able to delete files
      --prefix "PATH" : "${lib.makeBinPath [ glib.bin ]}"
      --suffix LD_LIBRARY_PATH : "$libpath"
        )
  '';

  postFixup =
    let prev = pkgs;
    in
    ''
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "$libpath" \
        $share/${pname}
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "$libpath" \
        $share/chrome-sandbox

      ${nodePackages.asar}/bin/asar extract $share/resources/app.asar tmp/app.asar.unpacked
      ${nodePackages.asar}/bin/asar extract $share/resources/webapp.asar tmp/webapp.asar.unpacked
      find tmp -name "*.node" -exec patchelf --set-rpath "$libpath" {} \;
      ${nodePackages.asar}/bin/asar pack tmp/app.asar.unpacked  $share/resources/app.asar
      ${nodePackages.asar}/bin/asar pack tmp/webapp.asar.unpacked  $share/resources/webapp.asar

      find $share -name "*.so" -exec patchelf --set-rpath "$libpath" {} \;
      find $share -name "*.bin" -exec patchelf --set-rpath "$libpath" {} \;
      find $share -name "*.node" -exec patchelf --set-rpath "$libpath" {} \;

      sed -i -e "s|Exec=.*$|Exec=${pname}|" $out/share/applications/${pname}.desktop
    '' + ''
      # use the turtleart.svg icon from the papirus theme
      for dir in $out/share/icons/hicolor/*; do
          res=$(basename "$dir")
          ${prev.imagemagick}/bin/convert -background none -density 1000 -resize "$res" -gravity center \
              ${prev.papirus-icon-theme}/share/icons/Papirus/64x64/apps/turtleart.svg \
              "$out/share/icons/hicolor/$res/apps/schildichat-desktop.png"
      done
      # actually only the png is relevant for linux appindicator icons
      ${prev.imagemagick}/bin/convert -background none -density 1000 -resize "256x256" -gravity center \
        ${./turtleart_bw.svg} \
        "$out/share/schildichat-desktop/resources/img/element.png"

      # we also need to replace the icons of the webapp,
      # see https://raw.githubusercontent.com/vector-im/element-web/06f434c313ca60aefb6e9e15f75018326ab2ae7d/scripts/make-icons.sh
      cp ${prev.papirus-icon-theme}/share/icons/Papirus/64x64/apps/turtleart.svg tmp/webapp.asar.unpacked/img/element-desktop-*.svg
      tmpdir=tmp/webapp.asar.unpacked/vector-icons

      for i in 1024 512 310 300 256 192 180 152 150 144 128 120 114 96 88 76 72 70 64 60 57 50 48 44 36 32 24 16; do
        ${prev.imagemagick}/bin/convert -background none -density 1000 -resize $i -extent $i -gravity center "${
          ./turtleart_bw.svg
        }" "$tmpdir/$i.png"
      done
      ${prev.imagemagick}/bin/convert -background none -density 1000 -resize 630x300 -gravity center "${
        ./turtleart_bw.svg
      }" "$tmpdir/310x150.png"
      ${prev.imagemagick}/bin/convert -background none -density 1000 -resize 1240x600 -gravity center "${
        ./turtleart_bw.svg
      }" "$tmpdir/310x150.png"

      ${prev.imagemagick}/bin/convert "$tmpdir/16.png" "$tmpdir/32.png" "$tmpdir/96.png" "$tmpdir/favicon.ico"
      for img in $tmpdir/favicon.*.ico; do
        cp $tmpdir/favicon.ico $img
      done

      ${prev.nodePackages.asar}/bin/asar pack tmp/webapp.asar.unpacked  $share/resources/webapp.asar
      # mv tmp/webapp.asar.unpacked  $share/resources/webapp.asar.unpacked
    '';
}
