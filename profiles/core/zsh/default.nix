{ config, lib, pkgs, ... }:
let
  inherit (builtins) concatStringsSep;

  inherit (lib) fileContents;

in {
  users.defaultUserShell = pkgs.zsh;

  environment = {
    systemPackages = with pkgs; [
      gnutar
      gzip
      lrzip
      p7zip
      unrar
      unzip
      xz

      zsh-completions
      nix-zsh-completions
    ];
  };

  programs.zsh = {
    enable = true;

    enableGlobalCompInit = false;

    histSize = 10000;

    setOptions = [
      "extendedglob"
      "incappendhistory"
      "sharehistory"
      "histignoredups"
      "histfcntllock"
      "histreduceblanks"
      "histignorespace"
      "histallowclobber"
      "autocd"
      "cdablevars"
      "nomultios"
      "pushdignoredups"
      "autocontinue"
      "promptsubst"
    ];

    promptInit = ''
      eval "$(${pkgs.starship}/bin/starship init zsh)"
    '';

    interactiveShellInit = let
      zshrc = fileContents ./zshrc;

      sources = with pkgs; [
        "${oh-my-zsh}/share/oh-my-zsh/plugins/sudo/sudo.plugin.zsh"
        "${oh-my-zsh}/share/oh-my-zsh/plugins/extract/extract.plugin.zsh"
        "${zsh-you-should-use}/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh"
        "${zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
        "${zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
        "${fzf-zsh}/share/zsh/plugins/fzf-zsh/fzf-zsh.plugin.zsh"
        "${zsh-autopair}/share/zsh/zsh-autopair/autopair.zsh"
        "${zsh-vi-mode}/share/zsh/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
        # keep at the end to ensure functionality https://github.com/jeffreytse/zsh-vi-mode/issues/15
        "${zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
      ];

      source = map (source: "source ${source}") sources;

      # HACK append time to nix-env
      plugins = concatStringsSep "\n" ([
        "${pkgs.any-nix-shell}/bin/any-nix-shell zsh --info-right | ${pkgs.gnused}/bin/sed -e \"s/\\(RPROMPT\\)=\\(.\\+\\)$/\\1='\\2 %F{037}%T%f'/g\" | source /dev/stdin"
      ] ++ source);

    in ''
      ${plugins}

      ${zshrc}

      eval "$(${pkgs.direnv}/bin/direnv hook zsh)"

      # needs to remain at bottom so as not to be overwritten
      # bindkey jj vi-cmd-mode
    '';
  };

}
