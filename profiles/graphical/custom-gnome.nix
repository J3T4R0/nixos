{ lib, pkgs, ... }:

with pkgs;
let
  extensions = with gnomeExtensions; [
    gsconnect # HACK does not work user installed
  ];

  additionalPackages = with gnome; [
    dconf-editor
    gnome-tweaks
    alacritty
    lollypop
    gnome.networkmanager-openvpn
    celluloid
    nautilus-python
    nextcloud-client
    qgnomeplatform
    peek # screen recordings for dummies
    # TODO nautilus terminal https://github.com/flozz/nautilus-terminal (see https://nixos.wiki/wiki/Python)
  ];
  excludePackages = with gnome; [
    # gedit
    gnome-weather
    # gnome-maps
    gnome-software
    gnome-music
    gnome-photos
    simple-scan
    totem
    # epiphany
    geary
  ];
in {

  networking.firewall = let
    gsconnectPortRange = {
      from = 1716;
      to = 1764;
    };
  in {
    allowedUDPPortRanges = [ gsconnectPortRange ];
    allowedTCPPortRanges = [ gsconnectPortRange ];
  };

  services = {
    gnome = {
      # chrome-gnome-shell.enable = false;
      # gnome-initial-setup.enable = false;
      sushi.enable = true;
    };
  };

  services.printing.enable = true;

  environment = {
    systemPackages = extensions ++ additionalPackages;
    gnome.excludePackages = excludePackages;
    # enable qgnomeplatform theme
    # we do this manualy to not force the style override
    variables.QT_QPA_PLATFORMTHEME = "gnome";
  };

  # services.gnome.evolution-data-server.enable = mkForce false;

}
