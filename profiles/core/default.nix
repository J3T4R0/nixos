{ self, config, lib, pkgs, ... }:
with pkgs;
let
  inherit (lib) fileContents;
  catls = writeShellScriptBin "catls" ''
    set -euo pipefail
    if [ $# -gt 0 ] && [ -f "''${!#}" ]; then
        ${bat}/bin/bat --color=always  "$@"
    else
        ${exa}/bin/exa  -lg --git "$@"
    fi
  '';
  cdl = writeShellScriptBin "cdl" ''
    set -euo pipefail
    cd  "$@" && ${exa}/bin/exa  -lg --git
  '';
  nru = writeShellScriptBin "nru" ''
    set -euo pipefail
    if [ -d /etc/nixos ]; then
        if [ $# -eq 0 ] || [ -n "$(echo "$@" | grep pkgs)" ]; then
            cd /etc/nixos/pkgs
            nix flake update "/etc/nixos/pkgs"
        fi
        cd /etc/nixos
        if [ $# -gt 0 ] && [ -n "$1" ]; then
            inputs=($@)
        else
            inputs=("nixos" "pkgs" "latest" "home" "emacs-overlay")
        fi
        args=""
        for input in "''${inputs[@]}"; do
            args="$args --update-input $input"
        done
        nix flake lock $args "/etc/nixos"
    fi
  '';
  nrt = writeShellScriptBin "nrt" ''
    cd /etc/nixos; sudo nixos-rebuild test --flake "/etc/nixos#$(hostname)" $@; cd -
  '';
in {

  imports = [
    ./locale.nix
    ./zsh
    ./vim
    ./nm.nix
    ../cachix
  ];

  environment = {

    systemPackages = with pkgs; [
      power-profiles-daemon # necessary for the CLI
      # core stuff
      binutils
      coreutils
      moreutils
      curl
      wget
      rsync
      direnv
      dosfstools
      gptfdisk
      util-linux
      # comfort tools
      git
      git-crypt
      fd
      ripgrep
      fzf
      whois
      gotop
      # htop
      exa
      bat
      manix # documentation for nix
      nix-index # files database for nix
      tealdeer # tldr
      direnv
      # custom functions
      catls
      cdl
      nru
      nrt
    ];

    # setup the starship_config and source the home-manager session variables
    shellInit = ''
      export STARSHIP_CONFIG=${
        pkgs.writeText "starship.toml" (lib.fileContents ./starship.toml)
      }
    '';

    shellAliases = let ifSudo = lib.mkIf config.security.sudo.enable;
    in {
      # because I am used to the ancestors
      htop = "gotop";
      top = "gotop";

      ls = "exa";
      ll = "ls -lg --git";
      l = "${catls}/bin/catls";
      la = "ll -a";
      tree = "exa -T";
      t = "tree";
      ta = "t -a";

      # human readable by default
      df = "df -h";
      du = "du -h";

      # quick cd
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";

      # git
      g = "git";

      # grep
      grep = "rg";
      gi = "grep -i";

      # internet ip
      myip = "dig +short myip.opendns.com @208.67.222.222 2>&1";

      # nix
      n = "nix";
      np = "n profile";
      npi = "np install";
      npr = "np remove";
      ns = "n search --no-update-lock-file";
      nf = "n flake";
      nepl = "n repl '<nixpkgs>'";
      srch = "ns nixos";
      orch = "ns override";
      nrb = ifSudo "sudo nixos-rebuild";

      # fix nixos-option
      nixos-option = "nixos-option -I nixpkgs=${toString ../../compat}";

      # list system generations
      nrl = ifSudo
        "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
      # remove old generations and collect garbage
      nrc = ifSudo "sudo nix-collect-garbage";
      nrd = ifSudo "sudo nix-collect-garbage -d";
      # Switch/test config
      nrs =
        ifSudo ''sudo nixos-rebuild switch --flake "/etc/nixos#$(hostname)"'';

      # systemd
      ctlu = "systemctl --user";
      ctl = "systemctl";
      stl = ifSudo "sudo systemctl";
      utl = "systemctl --user";
      jtl = "journalctl";
    };

    sessionVariables = {
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      LESS = "-FRX";
      LESSOPEN = "| bat --color=always %s";
      BAT_PAGER = "less";
    };
  };

  nix = {

    systemFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];

    autoOptimiseStore = true;

    gc.automatic = true;

    optimise.automatic = true;

    useSandbox = true;

    allowedUsers = [ "@wheel" ];

    trustedUsers = [ "root" "@wheel" ];

    extraOptions = ''
      min-free = 536870912
      keep-outputs = true
      keep-derivations = true
      fallback = true
    '';

  };

  programs = {

    gnupg.agent.enable = true;

    bash = {
      promptInit = ''
        eval "$(${pkgs.starship}/bin/starship init bash)"
      '';
      interactiveShellInit = ''
        eval "$(${pkgs.direnv}/bin/direnv hook bash)"
      '';
    };
  };

  security = {

    # FIXME takes no effect!! (check with ulimit -a)
    # nixos rebuilding texlive or running scripts that accesss alot of files needs higher ulimits
    pam.loginLimits = [{
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "4096"; # four times the default; hopefully sufficient
    }];

  };

  services = {
    earlyoom.enable = true;
    # try GNOME's power-profiles-daemon instead of TLP
    power-profiles-daemon.enable = true;

    openssh = {
      # For rage encryption, all hosts need a ssh key pair
      enable = true;
      openFirewall = lib.mkDefault false;
    };
  };

}
