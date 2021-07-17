{ config, lib, pkgs, ... }:
let
  serviceCfg = config.services.password-store-sync;
  programCfg = config.programs.password-store;
  pass-store = if config.xdg.enable then "${config.xdg.dataHome}/pass" else "";
in {
  programs = {
    password-store = {
      enable = true;
      package = pkgs.gopass;
      settings = {
        PASSWORD_STORE_DIR = pass-store;
        GOPASS_NO_NOTIFY = "1";
      };
    };
  };

  services = {
    # TODO wait until this matures a bit and has useful documentation
    # TODO we also need to stop the gnome provided one somehow
    # pass-secret-service.enable =
    #   true;
    password-store-sync = {
      enable = true;
      frequency = "hourly";
    };
  };
  # HACK use gopass
  systemd.user.services.password-store-sync.Service.ExecStart =
    lib.mkForce "${pkgs.gopass}/bin/gopass sync";

  programs.git.extraConfig.credential.helper = ''
    !PASSWORD_STORE_DIR="${pass-store}" ${pkgs.git-credential-gopass}/bin/git-credential-gopass  $@'';
}
