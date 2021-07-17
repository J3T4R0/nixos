{ config, lib, pkgs, ... }:
with pkgs;
let
  # we have overriden julia to be 1.5.3 from unstable
  julia = julia-stable-bin;
  d = version:
    "${lib.concatStringsSep "." (lib.take 2 (lib.splitString "." version))}";
  # HACK if python packages in julia break we need to "] build" in julia once
  julia-python = (python3.withPackages (ps:
    with ps; [
      sympy # sympy is mandatory for SymPy.jl
      jupyter # jupyter is not strictly necessary but convenient to have for IJulia.jl
      matplotlib # PyPlot.jl
      xlrd # ExcelFiles.jl
    ]));
  # Packages using the julia artifacts system should be able to download the necessary libraries automatically
  # But some packages rely on system packages, for these we need to install the libraries here
  extraLibs = [
    # stdenv.cc.cc.lib
    # # for FFMPEG (Plots animation)
    # HACK just symlink the ffmpeg binary to artifacts dir for now
    # freetype
    # libass
    # bzip2
    # zlib
    # openssl
    # ffmpeg-full
  ];
  extraBins = [
    gnumake # several packages need make (dependencies of BSON and FFTW [CRlibm])
    pdf2svg # display inline plots from PGFPlotsX, TODO texlive is also necessary but it works with the system binary...
    # ffmpeg-full
  ];
in
let
  mainVersion = d julia.version;
  julia-env = stdenv.mkDerivation rec {
    name = "julia-env";
    version = julia.version;

    nativeBuildInputs = [
      cacert
      git
      pkgconfig
      # incse we us a library relying on gtk/Qt in julia it might be usefull to wrap the library paths
      # qt5.wrapQtAppsHook
      # python only works with qt 5.14
      qt5.wrapQtAppsHook
      wrapGAppsHook

    ];
    # nativeBuildInputs = [ cacert git pkgconfig which makeWrapper ];

    dontWrapQtApps = true;
    dontWrapGApps = true;

    buildInputs = [ julia julia-python ] ++ extraLibs;
    phases = [ "installPhase" ];
    installPhase = ''
      # link everything from julia except bin
      mkdir -p $out
      for dir in ${julia}/*; do
          ln -s "$dir" $out/
      done
      rm $out/bin

      makeWrapperArgs+=("''${gappsWrapperArgs[@]}")

      # HACK we set JULIA_BINDIR such that build IJulia uses the wrapped julia in the kernel
      # makeQtWrapper ${julia}/bin/julia $out/bin/julia \
      makeWrapper ${julia}/bin/julia $out/bin/julia \
          --prefix PATH : $out/bin:${lib.makeBinPath [ julia-python ]} \
          --suffix PATH : ${lib.makeBinPath extraBins} \
          --suffix LD_LIBRARY_PATH : "${lib.makeLibraryPath extraLibs}" \
          --set PYTHONPATH "${julia-python}/${julia-python.sitePackages}" \
          --set PYTHON "${julia-python.interpreter}" \
          --set GRDIR ${gr} \
          --set JULIA_PKGDIR "$JULIA_PKGDIR" \
          --set JULIA_BINDIR "$out/bin/"
    '';
  };
in
{
  imports = [
    # TODO figure out best way to get the package from this and add it to the julia path
    ../texlive
  ];
  home.packages = [ julia-env ];
}
