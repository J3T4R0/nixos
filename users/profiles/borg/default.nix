{ config, pkgs, lib, ... }: {
  home.packages = with pkgs; [ borgbackup pika-backup ];
}
