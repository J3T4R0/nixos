{ config, lib, pkgs, ... }:
let
  repo-paths = ''
    (
      "/etc/nixos/"
      "$HOME/.config/doom/"
      "${config.programs.password-store.settings.PASSWORD_STORE_DIR}"
      # we can use regexps
      "$HOME/repos/*"
    )
  '';

  check-git-sh = with pkgs;
    writeShellScriptBin "check-git.sh" ''
      set -euo pipefail
      replace_file="/tmp/check-git-notification"

      # ensure all the dependencies are in PATH
      export PATH="${
        lib.makeBinPath [ notify-send-sh gnused coreutils git ]
      }:$PATH";

      paths=${repo-paths}
      uncommited=""

      for p in ''${paths[@]}; do
          # check for uncommited files
          if git -C "$p" status | grep "working tree clean" > /dev/null; then
              # check for unpushed commits to origin
              if git -C "$p" status | grep "origin" | grep "ahead" > /dev/null; then
                  uncommited="$uncommited$p (unpushed)\n"
              fi
          else
              uncommited="$uncommited$p\n"
          fi
      done

      if [ -n "$uncommited" ]; then
        # strip trailing \n
        uncommited="''${uncommited:0:-2}"
        notify-send.sh --replace-file="$replace_file" \
          --icon=git --app-name=git --hint=string:sound-name:bell-terminal \
          "$(echo -e "$uncommited" | wc -l) Git Repos Out of Sync" "$uncommited"
        echo "repos out of sync (notification send):"
        echo -e "$uncommited"
      else
        # if there are no uncommited messages delete the notification
        if [ -e $replace_file ]; then
          notify-send.sh -s "$(cat $replace_file)"
          rm $replace_file
          echo "no uncommited and unpushed commits in the relevant repos: notification deleted"
        else
          echo "no uncommited and unpushed commits in the relevant repos"
        fi
      fi
    '';

  pull-git-sh = with pkgs;
    writeShellScriptBin "pull-git.sh" ''
      set -euo pipefail

      # ensure all the dependencies are in PATH
      export PATH="${lib.makeBinPath [ gnused coreutils git ]}:$PATH";

      paths=${repo-paths}

      for p in ''${paths[@]}; do
          # check for uncommited files
          if git -C "$p" status | grep "working tree clean" > /dev/null; then
              # check for unpushed commits to origin, pull if the repo is not ahead
              git -C "$p" status | grep "origin" | grep "ahead" > /dev/null || \
                  git -C "$p" pull origin $(git -C "$p" branch --show-current) || echo Failed to pull "$p"
          fi
      done
    '';

in {

  services = { nextcloud-client.enable = true; };
  # we need to wait before starting nextcloud to ensure the indicator icon works

  home.packages = [ check-git-sh pull-git-sh ];

  systemd.user.services = {
    nextcloud-client = {
      Service = {
        ExecStartPre = lib.mkForce "${pkgs.coreutils}/bin/sleep 5";
        # Environment = lib.mkForce [ "PATH=${config.home.profileDirectory}/bin" "QT_QPA_PLATFORM=wayland" ];
      };
      Unit = {
        After = lib.mkForce [ "graphical-session.target" ];
        PartOf = lib.mkForce [ ];
      };
    };

    check-git = {
      Unit = { Description = "Check Git Repo Status of important repos"; };
      Service = { ExecStart = "${check-git-sh}/bin/check-git.sh"; };
    };

    pull-git = {
      Unit = { Description = "Try to pull from some important git repos"; };
      Service = { ExecStart = "${pull-git-sh}/bin/pull-git.sh"; };
    };
  };

  systemd.user.timers = {
    check-git = {
      Unit = {
        Description = "Check Git Repo Status of important repos";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Timer = {
        Unit = "check-git.service";
        OnCalendar = "*:0/5"; # all 5 minutes
        Persistent = true;
      };

      Install = { WantedBy = [ "timers.target" ]; };
    };

    pull-git = {
      Unit = {
        Description = "Try to pull from some important git repos";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Timer = {
        Unit = "pull-git.service";
        OnCalendar = "hourly";
        Persistent = true;
      };

      Install = { WantedBy = [ "timers.target" ]; };
    };
  };

}
