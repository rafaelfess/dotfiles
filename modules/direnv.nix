{pkgs, ...}: let
  homeDirectory =
    (
      if pkgs.stdenv.isDarwin
      then "/Users/"
      else "/home/"
    )
    + "rafael";
in {
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config = {
      global = {
        load_dotenv = true;
      };
      whitelist = {
        prefix = [
          "${homeDirectory}/Developer/rafaelfess/"
          "${homeDirectory}/Developer/charmbracelet/"
          "${homeDirectory}/Developer/goreleaser/"
        ];
      };
    };
  };
}
