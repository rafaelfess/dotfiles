{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    snap = {
      enable = lib.mkEnableOption "Snap support";
      packages = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "Name of the Snap package";
            };
            classic = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Whether to install the snap with --classic flag";
            };
          };
        });
        default = {};
        description = "Snap packages to install";
      };
    };
  };

  config = lib.mkIf config.snap.enable {
    # Default VSCode configuration
    snap.packages = {
      vscode = {
        name = "code";
        classic = true;
      };
    };

    # Enable snap support via nix-snapd
    services.snap.enable = true;

    # Create activation script to install snaps
    system.activationScripts.snapd-setup = {
      text = let
        installSnap = name: snap: ''
          # Install ${snap.name} via snap
          echo "Installing ${snap.name}..."
          /etc/profiles/per-user/root/bin/snap install ${snap.name} ${if snap.classic then "--classic" else ""}
        '';
      in ''
        # Wait for snapd to be fully started
        echo "Waiting for snapd service..."
        ${pkgs.coreutils}/bin/sleep 2

        # Install configured snaps
        ${lib.concatStrings (lib.mapAttrsToList installSnap config.snap.packages)}
      '';
      deps = [];
    };

    # Required system configuration
    environment.systemPackages = with pkgs; [
      coreutils
    ];
  };
}
