# Doom-Emacs setup, dependencies!
# https://github.com/hlissner/doom-emacs

{ config, lib, pkgs, ... }:

with lib;
let
  # 28 + native-comp + pgtk
  emacs = (with pkgs;
    (emacsPackagesGen emacsPgtkGcc).emacsWithPackages
    (epkgs: with epkgs; [ vterm pdf-tools zmq mu ]));

  # find and put binary dependencies of build packages in simpler places to use in the generated file
  emacs-deps = pkgs.stdenv.mkDerivation rec {
    name = "emacs-deps";
    version = pkgs.emacsPgtkGcc.version;

    buildInputs = [ emacs ];
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/share
      find ${emacs.deps}/share/emacs/site-lisp -name "epdfinfo" -exec ln -s {} $out/bin/epdfinfo \;
      find ${emacs.deps}/share/emacs/site-lisp -name "emacs-vterm-zsh.sh" -exec ln -s {} $out/share/emacs-vterm-zsh.sh \;
      find ${emacs.deps}/share/emacs/site-lisp -name "emacs-zmq.so" -exec ln -s {} $out/lib/emacs-zmq.so \;
    '';
  };
in {
  imports = [ ../texlive ];
  home.packages = with pkgs; [
    emacs
    binutils # native-comp needs 'as', provided by this

    ## Doom dependencies
    git
    (ripgrep.override { withPCRE2 = true; })
    gnutls # for TLS connectivity

    ## Optional dependencies
    fd # faster projectile indexing
    fzf # counsel fzf
    imagemagick # for image-dired
    # TODO look at this!!!
    # (mkIf (config.programs.gnupg.agent.enable)
    #   pinentry_emacs)   # in-emacs gnupg prompts
    zstd # for undo-fu-session/undo-tree compression

    ## Module dependencies
    # :checkers spell
    (aspellWithDicts (ds: with ds; [ en en-computers en-science de ]))
    # :checkers grammar
    languagetool
    # :tools editorconfig
    editorconfig-core-c # per-project style config
    # :tools lookup & :lang org +roam
    sqlite
    # :term vterm
    cmake
    gcc
    libtool
    libvterm

    # :lang sh
    shellcheck

    # :lang cc
    ccls
    # :lang nix
    nixfmt
    # :lang javascript
    # nodePackages.javascript-typescript-langserver
    # :lang latex & :lang org (latex previews)
    # org +jupyter
    # Already included additionally with sympy
    python-language-server
    (python38.withPackages (ps: with ps; [ jupyter ]))
    # :lang rust
    # rustfmt
    # unstable.rust-analyzer
    #
    #FONTS
    emacs-all-the-icons-fonts
    fira # variable pitch font
    (nerdfonts.override {
      fonts = [ "FiraCode" ];
    }) # monospace font with nerd patches
  ];

  home.sessionPath = if config.xdg.enable then
    [ "${config.xdg.configHome}/emacs/bin" ]
  else
    [ ".config/emacs/bin" ];

  xdg.configFile =
    let pass-store = config.programs.password-store.settings.PASSWORD_STORE_DIR;
    in {
      "doom/lisp/nixos.el".text = with pkgs; ''
        (after! langtool
          ;; Tell emacs where to find languagetool
          (setq
            langtool-java-bin "${jre}/bin/java"
            langtool-java-classpath "${languagetool}/share/*"
            langtool-language-tool-jar "${languagetool}/share/languagetool-commandline.jar"))

        (after! 'password-store
          (setq auth-source-pass-filename "${pass-store}"))

        (after! pdf-info
          (setq pdf-info-epdfinfo-program "${emacs-deps}/bin/epdfinfo"))

        (after! zmq
          (setq zmq-module-file "${emacs-deps}/lib/emacs-zmq.so"))

        (provide 'nixos)
      '';
    };

  programs.zsh.initExtra = ''
    source "${emacs-deps}/share/emacs-vterm-zsh.sh"
  '';

}
