final: prev: {
  # HACK fix build of iso.nix
  prev.linuxPackagesFor = kernel:
    (prev.linuxPackagesFor kernel).extend (final: final: { ati_drivers_x11 = null; });
}
