{ appimageTools, lib, fetchurl, polkit, udev }:

# It is necessary to add this package to
# services.udev.packages = with pkgs; [
#   uhk-agent
# ];
# for the udev rules to be activated
let
  pname = "uhk-agent";
  version = "1.5.14";
  name = "${pname}-${version}";
  src = fetchurl {
    url = "https://github.com/UltimateHackingKeyboard/agent/releases/download/v${version}/UHK.Agent-${version}-linux-x86_64.AppImage";
    name = "${name}.AppImage";
    sha256 = "sha256-D3sLjhWoeFVGgsFJo7/vsx4Dh8RsE+S6AA8z4Hsk8Ps=";
  };

  appimageContents = appimageTools.extract {
    name = "${pname}-${version}";
    inherit src;
  };
in appimageTools.wrapType2 {
  inherit src name;

  extraPkgs = pkgs: with pkgs; [ polkit udev ];

  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/${pname}

    install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'
    cp -r ${appimageContents}/usr/share/icons $out/share

    # user needs to be in the input group!
    install -D -m 644 ${appimageContents}/resources/rules/50-uhk60.rules $out/lib/udev/rules.d/50-uhk60.rules
  '';

  meta = with lib; {
    description = "Agent is the configuration application of the Ultimate Hacking Keyboard.";
    homepage = "https://github.com/UltimateHackingKeyboard/agent";
    license = "custom (older version GPLv3)";
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
  };
}
