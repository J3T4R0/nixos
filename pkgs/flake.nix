{
  description = "Package Sources";

  inputs = {
    FlyingFox = {
      url = "github:akshat46/FlyingFox";
      flake = false;
    };
    gnomeShellClock = {
      # url = "github:stuartlangridge/gnome-shell-clock-override";
      url = "github:sluedecke/gnome-shell-clock-override/gnome-40";
      flake = false;
    };
    notifySendSH = {
      url = "github:vlevit/notify-send.sh";
      flake = false;
    };
    popShell = {
      url = "github:pop-os/shell";
      flake = false;
    };
    restream = {
      url = "github:rien/reStream";
      flake = false;
    };
    remy = {
      url = "github:bordaigorl/remy/devel";
      flake = false;
    };
    soundconverter = {
      url = "github:kassoulet/soundconverter";
      flake = false;
    };
    tuxedo-touchpad-switch = {
      url = "github:tuxedocomputers/tuxedo-touchpad-switch";
      flake = false;
    };
    oreo-cursors = {
      url = "github:varlesh/oreo-cursors";
      flake = false;
    };
    # adwaita-cursors = {
    #   url = "github:manu-mannattil/adwaita-cursors";
    #   flake = false;
    # };
    gr = {
      url = "https://gr-framework.org/downloads/gr-latest-Debian-x86_64.tar.gz";
      flake = false;
    };
    zvm = {
      url = "github:jeffreytse/zsh-vi-mode";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, ... }: {
    overlay = final: prev: { inherit (self) srcs; };

    srcs =
      let
        inherit (nixpkgs) lib;

        mkVersion = name: input:
          let
            inputs = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes;

            ref =
              if lib.hasAttrByPath [ name "original" "ref" ] inputs then
                inputs.${name}.original.ref
              else
                "";

            version =
              let
                version' =
                  builtins.match "[[:alpha:]]*[-._]?([0-9]+(.[0-9]+)*)+" ref;
              in
              if lib.isList version' then
                lib.head version'
              else if input ? lastModifiedDate && input ? shortRev then
                "${lib.substring 0 8 input.lastModifiedDate}_${input.shortRev}"
              else
                null;
          in
          version;
      in
      lib.mapAttrs
        (pname: input:
          let version = mkVersion pname input;
          in
          input // {
            inherit pname;
          } // lib.optionalAttrs (!isNull version) { inherit version; })
        (lib.filterAttrs (n: _: n != "nixpkgs") self.inputs);
  };
}
