{ lib, stdenv, pkgs, fetchurl, wrapGAppsHook, glib, gtk3, atomEnv, libdrm, mesa
, nodePackages, libappindicator, polkit, rpmextract }:
stdenv.mkDerivation rec {
  pname = "tuxedo-control-center";
  version = "1.0.11";

  src = fetchurl {
    url =
      "https://deb.tuxedocomputers.com/ubuntu/pool/main/t/${pname}/${pname}_${version}_amd64.deb";
    sha256 = "sha256-wY83MFQEAEGNNmV7HHinhs51/MvPCZsHW3bB8n5RDAo=";
  };

  nativeBuildInputs = [
    wrapGAppsHook # Fix error: GLib-GIO-ERROR **: No GSettings schemas are installed on the system
  ];

  buildInputs = [
    # rpmextract
    gtk3 # Fix error: GLib-GIO-ERROR **: Settings schema 'org.gtk.Settings.FileChooser' is not installed
  ];

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = ''
    ar p $src data.tar.xz | tar xJ ./usr/ ./opt/
    # rpmextract $src
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin/"
    mv usr/share $out
    mv opt/${pname} "$out/share/${pname}"
    ln -sf "$out/share/${pname}/${pname}" "$out/bin/${pname}"
    ln -sf "$out/share/${pname}/resources/dist/tuxedo-control-center/data/service/tccd" "$out/bin/tccd"
    chmod +x "$out/share/${pname}/chrome-sandbox"

    runHook postInstall
  '';

  preFixup = ''
    share=$out/share/${pname}
    libpath="$share:${atomEnv.libPath}:${
      lib.makeLibraryPath [ libappindicator polkit ]
    }"
    gappsWrapperArgs+=(
      # needed for gio executable to be able to delete files
      --prefix "PATH" : "${lib.makeBinPath [ glib.bin ]}"
      --suffix LD_LIBRARY_PATH : "$libpath"
        )
  '';

  postFixup = ''
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "$libpath" \
      $share/${pname}
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "$libpath" \
      $share/chrome-sandbox

    data=$share/resources/dist/tuxedo-control-center/data/
    # patch the service daemon
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "$data/service/:$libpath" \
      $data/service/tccd

    ${nodePackages.asar}/bin/asar extract $share/resources/app.asar tmp/app.asar.unpacked
    find tmp -name "*.node" -exec patchelf --set-rpath "$libpath" {} \;
    ${nodePackages.asar}/bin/asar pack tmp/app.asar.unpacked  $share/resources/app.asar

    find $share -name "*.so" -exec patchelf --set-rpath "$libpath" {} \;
    find $share -name "*.bin" -exec patchelf --set-rpath "$libpath" {} \;
    find $share -name "*.node" -exec patchelf --set-rpath "$libpath" {} \;

    sed -i -e "s|Exec=.*$|Exec=${pname}|" $out/share/applications/${pname}.desktop
    install -m 444 -D $data/dist-data/com.tuxedocomputers.tccd.conf -t $out/share/dbus-1/system.d/
  '';
}
