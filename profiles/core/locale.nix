{ ... }:

{
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "en_US/ISO-8859-1"
      "en_IE.UTF-8/UTF-8"
      "en_IE/ISO-8859-1"
      "en_DK.UTF-8/UTF-8"
      "en_DK/ISO-8859-1"
      "de_DE.UTF-8/UTF-8"
      "de_DE/ISO-8859-1"
      "de_DE@euro/ISO-8859-15"
    ];
    extraLocaleSettings = {
      # use en_US for numbers (decimal point!)
      # en_IE also uses decimal point and is close enough for everything else, too
      LC_ALL = "en_IE.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      # iso,din (a4 paper) and metric systems in english
      # en_DK is like a en_EU version (also use either ireland or denmark in gnome settings)
      LC_TIME = "en_DK.UTF-8";
      LC_MEASUREMENT = "en_DK.UTF-8";
      LC_MONETARY = "en_DK.UTF-8";
      LC_PAPER = "en_DK.UTF-8";
      # for the rest use de_DE (hopefully here the language is irrelevant)
      LC_NAME = "de_DE.UTF-8";
      LC_ADDRESS = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
    };
  };
  time.timeZone = "Europe/Berlin";
}
