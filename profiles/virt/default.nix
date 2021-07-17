{ pkgs, ... }: {
  virtualisation = {
    libvirtd = {
      enable = true;
      qemuPackage = pkgs.qemu_kvm;
      qemuRunAsRoot = false;
    };

    # containers.enable = true;
    # podman.enable = true;
    # oci-containers.backend = "podman";
  };

  environment.systemPackages = with pkgs; [ gnome.gnome-boxes ];

  # environment.shellAliases.docker = "podman";

  # environment.sessionVariables = {
  #   VAGRANT_DEFAULT_PROVIDER = "libvirt";
  # };
}
