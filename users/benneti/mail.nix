{ config, lib, pkgs, ... }:
let
  index-mail-sh = with pkgs;
    writeShellScriptBin "index-mail.sh" ''
      set -euo pipefail
      # ensure all the dependencies are in PATH
      export PATH="${
        lib.makeBinPath [ mu notify-send-sh gnused coreutils ]
      }:$PATH";

      # small script to index mu and
      # send a notification if there are new mails
      set -euo pipefail
      replace_file="/tmp/index-mail-notification"

      mu index
      # ignore everything but the last line in case the script needs to be compiled
      unread_msgs=$(mu find "flag:unread AND NOT flag:trashed" || echo "nomail")
      if echo "$unread_msgs" | grep "nomail"; then
        # if there are no more unread emails close the notification
        if test -e $replace_file; then
          notify-send.sh -s "$(cat $replace_file)"
          rm $replace_file
          echo "no new mail: notification deleted"
        else
          echo "no new mail, no notification"
        fi
      else
        unread_count="$(echo "$unread_msgs" | wc -l)"
        unread_msgs=$(echo "$unread_msgs" | sed -r "s/^.+ ([^ ]+@[^ ]+) (.+)/<b>\1:<\/b> \2/")
        # making it is possible to ensure only one notification per program
        # and open emacs on click on the notification!
        notify-send.sh --replace-file="$replace_file" \
          --icon=mail-unread --app-name=mail --hint=string:sound-name:message-new-email \
          -d "emacs --eval '(=mu4e)'" \
          "Unread E-Mails ($unread_count)" "$unread_msgs"
        echo "new mail: notification send"
      fi
    '';

  # simple helper to set some recurring patterns of mail accounts
  # i.e. enable mbsync, show the passwordCommand
  #
  mkMail = args@{ address, ... }:
    args // rec {
      passwordCommand = if args ? passwordCommand then
        args.passwordCommand
      else
      # as we do not use the default pass we need some weirdness
        let store = config.programs.password-store.settings.PASSWORD_STORE_DIR;
        in "PASSWORD_STORE_DIR=${store} ${pkgs.gopass}/bin/gopass show mail/${address}";
      userName = if args ? userName then userName else address;
      realName = "Benedikt Tissot";
      mbsync = {
        enable = true;
        create = "maildir"; # mailboxes are managed on the server only!
        expunge = "both"; # but sync mail deletion accross all devices
      } // (if args ? mbsync then args.mbsync else { });
      msmtp = {
        enable = args ? smtp;
      } // (if args ? msmtp then args.msmtp else { });
      neomutt.enable = args ? smtp;
    };
in {
  home.packages = [ pkgs.mu ];
  programs = {
    mbsync.enable = true; # sync maildir
    msmtp.enable = true; # send mail
    neomutt.enable = true; # send mail with attachment still uses msmtp
  };

  services = {
    mbsync = {
      enable = true;
      postExec = "${index-mail-sh}/bin/index-mail.sh";
      frequency = "*:1/3"; # all 3 minutes
      # TODO xdg!
      # configFile =
    };
  };

  accounts.email.maildirBasePath = "${config.home.homeDirectory}/mail";
  accounts.email.accounts = {

    tissot = (mkMail {
      primary = true;
      address = "benedikt@tissot.de";
      imap.host = "imap.strato.de";
      smtp.host = "smtp.strato.de";
      mbsync = {
        groups.tissot.channels = {
          main = {
            patterns = [ "*" ''"!Sent Items"'' "!Sent" ];
            extraConfig.Create = "Near";
          };
          sent = {
            farPattern = "Sent Items";
            nearPattern = "Sent";
            extraConfig.Create = "Near";
          };
        };
      };
    });

    unikn = (mkMail {
      address = "benedikt.tissot@uni-konstanz.de";
      imap.host = "imap.uni-konstanz.de";
      smtp.host = "smtp.uni-konstanz.de";
      mbsync.patterns = [ "*" ];
    });

    google = (mkMail {
      address = "benedikt.tissot@googlemail.com";
      imap.host = "imap.gmail.com";
      smtp.host = "smtp.gmail.com";
      flavor = "gmail.com";
      mbsync = {
        groups.google.channels = {
          main = {
            patterns = [ "INBOX" ];
            extraConfig.Create = "Near";
          };
          sent = {
            farPattern = "[Google Mail]/Sent Mail";
            nearPattern = "Sent";
            extraConfig.Create = "Near";
          };
          trash = {
            farPattern = "[Google Mail]/Trash";
            nearPattern = "Trash";
            extraConfig.Create = "Near";
          };
          archive = {
            farPattern = "Archives";
            nearPattern = "Archive";
            extraConfig.Create = "Near";
          };
          drafts = {
            farPattern = "[Google Mail]/Drafts";
            nearPattern = "Drafts";
            extraConfig.Create = "Near";
          };
          spam = {
            farPattern = "[Google Mail]/Spam";
            nearPattern = "Spam";
            extraConfig.Create = "Near";
          };
        };
      };
    });

    cloud = (mkMail {
      address = "benneti@cloud.tissot.de";
      imap.host = "cloud.tissot.de";
      # we do not use this one to send mail
      mbsync.patterns = [ "*" ];
    });

    mpl = (mkMail {
      address = "benedikt.tissot@mpl.mpg.de";
      imap.host = "email.gwdg.de";
      smtp.host = "email.gwdg.de";
      smtp.port = 587;
      smtp.tls.useStartTls = true;
      mbsync = {
        extraConfig.account.AuthMechs = "Login";
        patterns = [ "INBOX" "Archive" "Trash" "Sent" "Drafts" ];
      };
      msmtp.extraConfig = { auth = "login"; };
    });

  };
}
