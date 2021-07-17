{ config, lib, pkgs, ... }:
let
  inherit (builtins) listToAttrs;

  packages = with pkgs; [
    calibre
    libreoffice-fresh
    inkscape
    gimp
    schildichat-desktop
    chromium # sometimes firefox doesn't work...
  ];

  gnome-extensions = with pkgs.gnomeExtensions; [ dash-to-panel ];
  uuid = e:
    if e ? extensionUuid
    then e.extensionUuid
    else e.uuid;

in
{
  home-manager.users.leonie = {
    home.packages = packages;

    xdg.dataFile = listToAttrs
      (map
        (e:
          let target = "gnome-shell/extensions/${(uuid e)}"; in
          {
            name = target;
            value = {
              # recursive = true;
              recursive = false; # hopefully makes it impossible for gnome to update my extensions
              source = "${e}/share/${target}";
            };
          })
        gnome-extensions);

    dconf.settings = with lib.hm.gvariant; {
      "org/gnome/shell" = {

        disable-user-extensions = false;
        enabled-extensions = (map uuid gnome-extensions);

        favorite-apps = [
          "firefox.desktop"
          "startcenter.desktop" # libreoffice
          "schildichat-desktop.desktop"
          "org.gnome.Nautilus.desktop" # files
          "chromium-browser.desktop"
        ];
      };
    };

  };


  users.users.leonie = {
    uid = 1002;
    hashedPassword = "$6$T.ci8xNzRY$J10sMvog2raU9cXDsusXfpBQa8lDYzt4AL4DfojrKZ9CeRZpCzIcsCd1Q/tMzAmZ0WLAlEaxE4EFOnnlxmTOT.";
    description = "Leonie Ullherr";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "input" ];
    shell = pkgs.zsh;
  };

}
