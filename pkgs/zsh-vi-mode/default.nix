{ stdenv, lib, srcs }:
let inherit (srcs) zvm;
in stdenv.mkDerivation rec {
  pname = "zsh-vi-mode";
  inherit (zvm) version;
  src = zvm;

  installPhase = ''
    install -D zsh-vi-mode.zsh $out/share/zsh/${pname}/zsh-vi-mode.zsh
    install -D zsh-vi-mode.plugin.zsh $out/share/zsh/${pname}/zsh-vi-mode.plugin.zsh
  '';

  meta = with lib; {
    homepage = "https://github.com/jeffreytse/zsh-vi-mode";
    description = "A better and friendly vi(vim) mode plugin for ZSH.";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
