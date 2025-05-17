{
  config,
  pkgs,
  lib,
  ...
}: {
  # Enable Flatpak support
  services.flatpak.enable = true;

  # Configure Flatpak packages and repository
  system.activationScripts.flatpak-packages = {
    text = ''
      # Add Flathub repository
      ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

      # Install Zen Browser
      ${pkgs.flatpak}/bin/flatpak install -y flathub app.zen_browser.zen
      ${pkgs.flatpak}/bin/flatpak install -y flathub dev.zed.Zed
      ${pkgs.flatpak}/bin/flatpak install -y flathub org.telegram.desktop
      ${pkgs.flatpak}/bin/flatpak install -y flathub com.spotify.Client
      ${pkgs.flatpak}/bin/flatpak install -y flathub com.rustdesk.RustDesk
    '';
    deps = [];
  };
}
