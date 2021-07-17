{ config, lib, pkgs, ... }:
let
  inherit (config.home) homeDirectory;
  ifPass = lib.mkIf config.programs.password-store.enable;
  gopass-wrapper =
    let pass-store = config.programs.password-store.settings.PASSWORD_STORE_DIR;
    in with pkgs;
    writeShellScriptBin "gopass_wrapper.sh" ''
      export PATH="$PATH:${lib.makeBinPath [ gnupg pinentry_gnome ]}";

      if [ -f ~/.gpg-agent-info ] && [ -n "$(pgrep gpg-agent)" ]; then
        source ~/.gpg-agent-info
        export GPG_AGENT_INFO
      else
        eval $(gpg-agent --daemon)
      fi

      export GPG_TTY="$(tty)"
      export PASSWORD_STORE_DIR="${pass-store}"

      ${gopass-jsonapi}/bin/gopass-jsonapi listen

      exit $?
    '';
in {
  # # FIXME
  # programs.firefox = {
  #   enable = true;
  #   package = pkgs.firefox-wayland;
  #   # extensions are synced including settings over my firefox account
  #   # extensions = with pkgs.nur.repos.rycee.firefox-addons; [
  #   #   gopass-bridge
  #   #   darkreader
  #   #   https-everywhere
  #   #   multi-account-containers
  #   #   ublock-origin
  #   #   unpaywall
  #   #   # TODO not in nur
  #   #   # wallabager
  #   #   # crossref search
  #   #   # not so important
  #   #   # amazon.de suche
  #   #   # beyond 20
  #   #   # cookies.txt
  #   # ]; # TODO
  #   # https://github.com/akshat46/FlyingFox
  #   profiles.default = {
  #     id = 0;
  #     isDefault = true;
  #     settings = {

  #     };
  #     extraConfig = ''
  #     '';
  #   };
  # };

  home.file = let
    cfgPath = "${homeDirectory}/.mozilla/firefox";
    # profile = config.programs.firefox.profiles.default;
    # profilePath = "${cfgPath}/${profile.path}";
    profilePath = "${cfgPath}/default";
  in {
    "profiles.ini" = {
      text = ''
        [General]
        StartWithLastProfile=1

        [Profile0]
        Default=1
        IsRelative=1
        Name=default
        Path=default
      '';
      target = "${cfgPath}/profiles.ini";
    };
    flyingFox = {
      recursive = true;
      source = "${pkgs.flyingfox}/chrome";
      target = "${profilePath}/chrome";
    };
    # todo we need to merge this with other custom settings?
    flyingFox_userjs = {
      source = "${pkgs.flyingfox}/user.js";
      target = "${profilePath}/user.js";
    };
    flyingFox_config = {
      source = ./FlyingFox_config.css;
      target = "${profilePath}/chrome/config.css";
    };
    "${homeDirectory}/.mozilla/native-messaging-hosts/com.justwatch.gopass.json".text =
      ''
        {
            "name": "com.justwatch.gopass",
            "description": "Gopass wrapper to search and return passwords",
            "path": "${gopass-wrapper}/bin/gopass_wrapper.sh",
            "type": "stdio",
            "allowed_extensions": [
                "{eec37db0-22ad-4bf1-9068-5ae08df8c7e9}"
            ]
        }
      '';
  };
}
