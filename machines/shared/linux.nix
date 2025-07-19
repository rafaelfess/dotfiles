{pkgs, ...}: {
  imports = [
    # ./tailscale.nix
  ];

  # Bootloader.
  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "/dev/sda";
  # boot.loader.grub.useOSProber = true;
  # boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  security.sudo.extraRules = [
    {
      users = ["rafael"];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  # User Account Configuration
  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.rafael = {
    isNormalUser = true;
    description = "Rafael";
    extraGroups = [
      "wheel" # Enable sudo
      "networkmanager"
      # "video"
      # "audio"
    ];
    shell = pkgs.fish;
    # openssh.authorizedKeys.keys = [
    #   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDL4TbfX8mBhJS/MeA90fy2JNRtCQK7qEs+fqXHnNzFl rafaelfess@bleesoft.com"
    # ];
    # packages = with pkgs; [ ];
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings = {
      auto-optimise-store = true;
      # nix config show | grep download-buffer-size
      download-buffer-size = "8192M";
      substituters = [
        # "https://caarlos0.cachix.org"
        # "https://charmbracelet.cachix.org"
        # "https://goreleaser.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        # "caarlos0.cachix.org-1:+isrUkB/il038Bpn7P8Gy1YrJ31uIyvk/+nBrQg4M+w="
        # "charmbracelet.cachix.org-1:iA+l3/8TVJsKR9h28f7f0C0CYA9JjI24yJ8YlGabbkg="
        # "goreleaser.cachix.org-1:zoswTZ5hfNwaUOEZ869pjxjXIp5HMkgQXWK/vwrl158="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-users = [
        "root"
        "rafael"
        "@wheel"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  environment.systemPackages = with pkgs; [
    alejandra
    cachix
    coreutils
    curl
    git
    jq
    unzip
    wget
    # Tools
    globalping-cli
    cloudflared
    # Terminal tools
    ghostty
    kitty
    # Editors
    helix
    # Browsers
    firefox
    brave
    vivaldi
    # Communication
    discord
    element-desktop
    # Development Tools
    jetbrains-toolbox
    sublime-merge
    # Media
    vlc
    # Remote Desktop Client
    remmina
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # Browsers
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition;
  };

  programs.fish.enable = true;

  services.openssh.enable = false;
  services.cron.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      domain = true;
      addresses = true;
    };
  };

  # XDG Desktop Portal
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [pkgs.xdg-desktop-portal-gnome];
    config.common.default = "*";
  };

  # Sound Configuration
  services.pulseaudio.enable = false; # Use PipeWire instead
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  # Printing Support
  services.printing.enable = true;

  # Power Management
  systemd = {
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };
}
