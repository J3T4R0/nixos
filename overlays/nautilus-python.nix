final: prev: {
  __dontExport = true; # overrides clutter up actual creations
  gnome = prev.gnome // {
    nautilus = prev.gnome.nautilus.overrideAttrs (o: rec {
      preFixup = with prev;
        let py = (python3.withPackages (ps: with ps; [ ps.pygobject3 ]));
        in ''
          gappsWrapperArgs+=(
            # Thumbnailers
            --prefix XDG_DATA_DIRS : "${gdk-pixbuf}/share"
            --prefix XDG_DATA_DIRS : "${librsvg}/share"
            --prefix XDG_DATA_DIRS : "${shared-mime-info}/share"
            --prefix PYTHONPATH : ${py}/${py.sitePackages}
            )
        '';
    });
  };
}
