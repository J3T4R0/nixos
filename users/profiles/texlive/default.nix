{ config, lib, pkgs, ... }:
let
  # tl = pkgs.texlive.combine {
  #   inherit (pkgs.texlive) scheme-medium;
  #   # see nixpkgs/pkgs/tools/typesetting/tex/texlive/combine.nix
  #   pkgFilter = (pkg:
  #     pkg.tlType == "run" || pkg.tlType == "bin" || pkg.pname == "core"
  #     || pkg.tlType == "doc");
  # };
  tl = pkgs.texlive.combined.scheme-full;
in {
  home.packages = [
    tl
    pkgs.jabref # replace journals with abbreviations automatically
  ];
  # latexmk to create pdf with lualatex and disable security
  home.file.".latexmkrc".text = ''
    $pdf_mode = 4;
    $postscript_mode = $dvi_mode = 0;
    $pdflualatex = 'lualatex -synctex=1 -shell-escape -enable-write18 -file-line-error %O %S';
  '';
}
