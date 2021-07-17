{ config, lib, pkgs, ... }:

{
  networking.networkmanager = {
    enable = true;
    # wifi.backend = "iwd";
  };

  # HACK assuming the config is in /etc/nixos
  #      we copy connections added/changed in the NM settings
  system.activationScripts = {
    system-connections.text = ''
      scnm="/etc/NetworkManager/system-connections"
      sce="/etc/nixos/secrets/system-connections"
      if [ -d "$sce" ] && [ -d "$scnm" ]; then
        # incase we changed connections copy them to the repo
        # cp "$scnm"/* "$sce"/
        shopt -s nullglob # no match means no iteration
        for con in "$scnm/"*.nmconnection; do
          bcon=$(basename "$con")
          ${pkgs.gnused}/bin/sed -r "s/(uuid|interface-name)=.+$//" "$con" > "$sce/$bcon"
        done
        # ensure wheel can rw connections
        chown -R root:wheel "$sce"
        chmod -R g+rw "$sce"
        chmod  g+x "$sce"
      fi
      # copy the configuration from the store to NM
      shopt -s nullglob # no match means no iteration
      for con in ${../../secrets}/system-connections/*.nmconnection; do
        # for some reason NetworkManager thinks
        # it is a good Idea to have whitespace in filenames
        install -m 0600 -o root -g root -D "$con" "$scnm"/
      done
      for ca in ${../../secrets}/system-connections/.*ca.pem; do
        install -m 0600 -o root -g root -D "$ca" "$scnm"/
      done
    '';
  };

}
