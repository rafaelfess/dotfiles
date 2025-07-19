# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').
{
  pkgs,
  config,
  ...
}: {
  imports = [
    ../shared/linux.nix
    ./hardware.nix
    ../shared/graphics_nvidia.nix
    ../../modules/desktop/gnome.nix
  ];

  programs.ssh = {
    startAgent = true;
    agentTimeout = "1h";
    # extraConfig = ''
    #   AddKeysToAgent yes
    # '';
    enableAskPassword = true;
  };

  systemd.user.services.ssh-add = {
    description = "Add SSH keys to agent";
    wantedBy = ["default.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.openssh}/bin/ssh-add ~/.ssh/com_bleesoft_r__dev_id";
      RemainAfterExit = "yes";
    };
  };

  networking.hostName = "darkstar";

  # https://nixos.wiki/wiki/Fonts
  # 24.11 (or earlier)
  # https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
  # fonts.packages = with pkgs; [
  #   (nerdfonts.override {fonts = ["JetBrainsMono"];})
  # ];
  # 25.05 (or later)
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.jetbrains-mono
  ];

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = false;
      defaultNetwork.settings.dns_enabled = true;
    };
    docker = {
      enable = true;
      daemon = {
        settings = {
          dns = ["1.1.1.1"];
        };
      };
      autoPrune = {
        enable = true;
      };
    };
  };

  users.users.rafael.extraGroups = [
    "podman"
    "docker"
    "video" # Required for OBS virtual camera access
    "input" # Required for device/video access
  ];

  services.teamviewer.enable = true;

  # this allows to cross-build docker images, for example.
  # akin to https://github.com/docker/setup-qemu-action
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];

  services.qemuGuest.enable = true;
  # services.postgresql = {
  #   enable = true;
  #   ensureDatabases = ["rafael"];
  #   ensureUsers = [
  #     {
  #       name = "rafael";
  #       ensureClauses = {
  #         login = true;
  #         createrole = true;
  #         createdb = true;
  #         superuser = true;
  #       };
  #     }
  #   ];
  #   authentication = pkgs.lib.mkOverride 10 ''
  #     # TYPE  DATABASE        USER            ADDRESS                 METHOD
  #     local   all             all                                     trust
  #     host    all             all             127.0.0.1/32            trust
  #     host    all             all             ::1/128                 trust
  #   '';
  # };

  # Enable OBS Studio with DroidCam support and virtual camera
  # Note: This adds kernel modules and requires a reboot after applying
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    plugins = with pkgs.obs-studio-plugins; [
      droidcam-obs
      obs-multi-rtmp
      wlrobs
    ];
  };

  # Additional video format support
  nixpkgs.config.packageOverrides = pkgs: {
    v4l2loopback = pkgs.v4l2loopback.override {
      kernel = config.boot.kernelPackages.kernel;
      enableYUYV = true;
      enableNV12 = true;
      enableH264 = true;
      bufferSize = 16;
    };
  };

  # Enable NVENC support through NVIDIA driver packages
  hardware.opengl = {
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
    ];
    extraPackages32 = with pkgs; [
      nvidia-vaapi-driver
    ];
  };

  # Configure v4l2loopback for OBS virtual camera
  boot.extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];
  boot.kernelModules = ["v4l2loopback"];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Virtual Camera" exclusive_caps=1 max_buffers=8 max_width=1920 max_height=1080 default_width=1280 default_height=720 default_fps=30
  '';

  environment.systemPackages = with pkgs; [
    dig
    # coreutils-full
    # gcc
    # grpcurl
    inetutils
    # kind
    # python312Packages.tqdm
    # util-linux
    docker
    docker-compose
    # fswatch
    teamviewer
    v4l-utils # Adds v4l2-ctl and other video utilities
  ];

  networking.firewall.allowedTCPPortRanges = [
    {
      from = 1024;
      to = 65535;
    } # high ports
  ];

  systemd.timers."backup" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
  };

  # NOTE: need to run `rclone config` once for it to work.
  # systemd.services."backup" = {
  #   path = with pkgs; [
  #     rclone
  #     curl
  #     openssh
  #   ];
  #   script = ''
  #     rclone sync -v \
  #       --no-update-modtime \
  #       --disable PartialUploads \
  #       --links \
  #       --exclude 'Go/' \
  #       --exclude 'forks/' \
  #       --exclude '**/.direnv/' \
  #       --exclude '**/dist/' \
  #       --exclude '**/.git/' \
  #       $HOME/Developer/ nas:/darkstar/
  #     rclone copy $HOME/.localrc.fish nas:/darkstar/
  #     rclone copy $HOME/.local/share/fish/fish_history nas:/darkstar/
  #     curl -sf https://hc-ping.com/$(cat $HOME/Developer/.PING_ID)
  #   '';
  #   serviceConfig = {
  #     Type = "oneshot";
  #     User = "rafael";
  #   };
  # };

  # Enable AppImage support
  # appimage.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
