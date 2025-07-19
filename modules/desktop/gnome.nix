{
  config,
  pkgs,
  ...
}: {
  # X11 and Wayland Configuration
  services.xserver = {
    enable = true;
    # Display Manager and Desktop Environment
    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
      };
    };
    desktopManager.gnome.enable = true;

    # Keyboard Configuration
    xkb = {
      layout = "us,us";
      variant = ",intl";
      options = "grp:win_space_toggle";
    };
    exportConfiguration = true;
  };

  # Mouse Configuration
  services.libinput.mouse = {
    accelProfile = "flat";
  };

  # Compose key configuration for correct cedilla
  environment.etc."X11/locale/compose.dir".text = ''
    en_US.UTF-8/Compose: compose.cedilla
  '';

  # Configure GTK and Qt input methods for cedilla support
  environment.variables = {
    GTK_IM_MODULE = "cedilla";
    QT_IM_MODULE = "cedilla";
    # Enable hardware acceleration
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm"; # Required for proper Wayland support
    LIBGL_ALWAYS_SOFTWARE = "0"; # Force hardware OpenGL
    WLR_NO_HARDWARE_CURSORS = "1"; # Fix potential cursor issues on NVIDIA Wayland
    MOZ_DISABLE_RDD_SANDBOX = "1"; # Required for some hardware acceleration cases
    NVD_BACKEND = "direct"; # Better performance for the NVIDIA driver
  };

  # Configure GTK IMModules to include cedilla for en_US
  system.userActivationScripts.gtk-immodule-file = {
    text = ''
      ${pkgs.glib}/bin/glib-compile-schemas "${pkgs.gtk3}/share/glib-2.0/schemas"
      ${pkgs.gtk3}/bin/gtk-query-immodules-3.0 --update-cache
      ${pkgs.gtk2}/bin/gtk-query-immodules-2.0-64 --update-cache
    '';
    deps = [];
  };

  environment.etc."X11/locale/en_US.UTF-8/Compose".text = ''
    include "%L"

    # Custom cedilla rules
    <dead_acute> <c> : "ç"
    <dead_acute> <C> : "Ç"
  '';

  # GNOME Keyboard Layout Auto-configuration
  environment.etc."xdg/autostart/keyboard-layout.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Exec=/usr/bin/gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'us+intl')]"
    Hidden=false
    NoDisplay=false
    X-GNOME-Autostart-enabled=true
    Name=Set Keyboard Layout
    Comment=Set keyboard layout at startup
  '';

  # Display Manager Restart Script
  system.activationScripts.text = ''
    if [[ -e /run/gdm.pid ]]; then
      kill -HUP $(cat /run/gdm.pid)
    fi
  '';

  # Desktop Environment Packages
  environment.systemPackages = with pkgs; [
    # GNOME Extensions and Tools
    gnomeExtensions.dash-to-dock
    gnomeExtensions.color-picker
    # gnomeExtensions.system-monitor-tray-indicator
    gnomeExtensions.astra-monitor
    gnomeExtensions.zilence
    gnome-tweaks
    # GNOME Applications
    # https://chatgpt.com/c/67a14bd7-e6f4-8012-9b61-40ad317260fb
    gnome-settings-daemon
    gnome-control-center
    dconf-editor
    # Media Playback
    totem # GNOME Videos player
    libva-utils # VA-API utilities
    # Clipboard Support
    wl-clipboard # Wayland clipboard utilities
    xclip # X11 clipboard utilities (fallback)
  ];

  services.gnome.gnome-settings-daemon.enable = true;
}
