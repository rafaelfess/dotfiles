{
  lib,
  pkgs,
  ...
}: {
  home.username = "rafael";
  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself.
  home.homeDirectory = lib.mkForce "/home/rafael";
  programs.home-manager.enable = true;
  programs.nix-index.enable = true;

  home.packages = with pkgs; [
    # spotify
  ];

  # home.file.".cloudflared/config.yml".text = ''
  #   tunnel: phoenix
  #   credentials-file: ${builtins.getEnv "HOME"}/.cloudflared/phoenix.json

  #   ingress:
  #     - hostname: phoenix-dev.bleesoft.com
  #       service: http://127.0.0.1:4000
  #     - service: http_status:404
  # '';

  home.sessionVariables = {
    LC_ALL = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    PROJECTS = "$HOME/Developer";
    XDG_CURRENT_DESKTOP = "GNOME"; # Added for proper desktop integration
  };

  # ensures ~/Developer folder exists.
  # this folder is later assumed by other activations, specially on darwin.
  home.activation.developer = ''
    mkdir -p ~/Developer
  '';

  # Add XDG MIME type configuration for Zen Browser
  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/http" = ["app.zen_browser.zen"];
        "x-scheme-handler/https" = ["app.zen_browser.zen"];
        "text/html" = ["app.zen_browser.zen"];
        "application/xhtml+xml" = ["app.zen_browser.zen"];
      };
    };
  };

  dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      # Button in the right side of the screen
      # "button-layout" = "appmenu:minimize,maximize,close";
      # Button in the left side of the screen
      "button-layout" = "close,minimize,maximize:appmenu";
    };
  };
}
