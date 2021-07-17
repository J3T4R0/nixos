# tuxedo control center setup
{ config, lib, pkgs, ... }: {

  boot = {
    # kernelModules = [ "tuxedo_keyboard" "tuxedo_io" ]; # the modules get loaded as needed
    extraModulePackages = with config.boot.kernelPackages;
      [
        (tuxedo-keyboard.overrideAttrs (self: rec {
          version = "3.0.7";

          src = pkgs.fetchFromGitHub {
            owner = "tuxedocomputers";
            repo = "tuxedo-keyboard";
            rev = "v${version}";
            sha256 = "sha256-JloLwfJfDdVowx1hOehjxPbnaKBCAMn7SZe09SE03HU=";
          };

          makeFlags = self.makeFlags ++ [ "all" ];
          installPhase = self.installPhase + ''
            find src -name "*.ko" -exec mv {} $out/lib/modules/* \;
          '';
        })) # HACK newest version as well as all kernel modules package
      ];
  };
  environment.systemPackages = with pkgs;
    [
      # tuxedo-control-center # FIXME the daemon is broken
      tuxedo-touchpad-switch
    ];
  services.udev.packages = with pkgs; [ tuxedo-touchpad-switch ];
  # copyed from "${tuxedo-control-center}/share/tuxedo-control-center/resources/dist/tuxedo-control-center/data/dist-data"
  # systemd.services.tccd = with pkgs; {
  #   description = "TUXEDO Control Center Service";
  #   path = with pkgs; [ systemd tuxedo-control-center ];

  #   serviceConfig.Type = "simple";
  #   script = "tccd --start";
  #   preStop = "tccd --stop";

  #   wantedBy = [ "multi-user.target" ];
  # };

  # systemd.services.tccd-sleep = with pkgs; {
  #   description = "TUXEDO Control Center Service (sleep/resume)";
  #   before = [ "sleep.target" ];
  #   unitConfig.StopWhenUnneeded = "yes";

  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = "yes";
  #   };
  #   script = "systemctl stop tccd";
  #   preStop = "systemctl start tccd";

  #   wantedBy = [ "sleep.target" ];
  # };
}
