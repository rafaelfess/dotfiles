{
  config,
  lib,
  pkgs,
  ...
}: {
  # Enable OpenGL with NVIDIA support
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiVdpau        # VDPAU-based VA-API implementation
      libvdpau-va-gl    # VA-API to VDPAU/OpenGL bridge
      nvidia-vaapi-driver  # NVIDIA VA-API driver
      libGL             # OpenGL implementation
      libglvnd          # GL Vendor-Neutral Dispatch library
      mesa              # OpenGL implementation
      egl-wayland       # EGL support for Wayland
      vulkan-loader     # Vulkan support
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vaapiVdpau
      libvdpau-va-gl
      nvidia-vaapi-driver
      libGL
      libglvnd
    ];
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Modesetting is required for Wayland
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Enable the NVIDIA persistence daemon for better stability
    nvidiaPersistenced = true;

    # Force full composition pipeline for better performance
    forceFullCompositionPipeline = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
