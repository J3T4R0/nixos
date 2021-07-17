self: super: {
  python3 = super.python3.override {
    packageOverrides = python-self: python-super: {
      poppler-qt5 = python-super.poppler-qt5.overrideAttrs (oldAttrs: {
        src = python-super.fetchPypi {
          pname = "python-poppler-qt5";
          version = "21.1.0";
          sha256 = "sha256-rddm2ywEAmpgh/OPIETmbIsFPIEALzdT2AWXE0l9Ai0=";
        };
        patches = [
          (super.substituteAll {
            src = ../pkgs/python3-poppler-qt5/poppler-include-dir.patch;
            poppler_include_dir = "${super.libsForQt5.poppler.dev}/include/poppler";
          })
          (super.fetchpatch {
            url = "https://patch-diff.githubusercontent.com/raw/frescobaldi/python-poppler-qt5/pull/45.patch";
            sha256 = "sha256-Jf6GeESgH9BxguozF1Qz6Q++TRfpISqt0MKGdSZoIzE=";
          })
        ];
      });
    };
  };
}
