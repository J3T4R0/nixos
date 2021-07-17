{ lib, pkgs, ... }:

{
  fonts = {
    fonts = with pkgs; [
      powerline-fonts
      # dejavu_fonts # default sans font
      fira
      eb-garamond # serif font with nice ligatures
      fira-code # monospace font
      (nerdfonts.override {
        fonts = [ "FiraCode" ];
      }) # monospace font with nerd patches
      # nerdfonts # monospace font with nerd patches
      noto-fonts-emoji # support emojis
    ];

    fontconfig.defaultFonts = {
      monospace = [ "FiraCode Nerd Font" ];
      # monospace = [ "Fira Code" ];
      serif = [ "EB Garamond" ];
      sansSerif = [ "Fira Sans" ];
    };
  };

}
