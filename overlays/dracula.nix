final: prev: {
  dracula-theme = prev.dracula-theme.overrideAttrs (o: {
    src = prev.fetchFromGitHub {
      owner = "dracula";
      repo = "gtk";
      rev = "dcd159fc3dc668422064c871e49a0df3cc515203";
      hash = "sha256-u5S3g+j8M6ZIxeyN/FI4AJZ2h39bXoU7j5iIhzzU9OM=";
    };
  });
}
