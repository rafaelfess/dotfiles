{
  description = "rafael's nixos, nix-darwin, and home-manager configs";
  inputs = {
    # Core dependencies
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Snap support
    nix-snapd = {
      url = "github:nix-community/nix-snapd";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Utils
    flake-utils.url = "github:numtide/flake-utils";
    flake-parts.url = "github:hercules-ci/flake-parts";

    # User environment management
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Additional utilities
    nix-colors.url = "github:misterio77/nix-colors";
    nur.url = "github:nix-community/NUR";

    # System indexing and searching
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # caarlos0-nur.url = "github:caarlos0/nur";
    # charmbracelet-nur.url = "github:charmbracelet/nur";
    # goreleaser-nur.url = "github:goreleaser/nur";
    # # neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nur,
    nix-snapd,
    # , neovim-nightly
    # caarlos0-nur,
    # charmbracelet-nur,
    # goreleaser-nur,
    darwin,
    home-manager,
    nix-index-database,
    nixpkgs,
    nixpkgs-unstable,
    ...
  }: let
    overlays = [
      # inputs.neovim-nightly.overlay
      (_final: prev: {
        nur = import nur {
          nurpkgs = prev;
          pkgs = prev;
          # repoOverrides = {
          #   caarlos0 = import caarlos0-nur {pkgs = prev;};
          #   charmbracelet = import charmbracelet-nur {pkgs = prev;};
          #   goreleaser = import goreleaser-nur {pkgs = prev;};
          # };
        };
      })
    ];

    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.unix;

    nixpkgsFor = forAllSystems (
      system:
        import nixpkgs {
          inherit system;
          overlays = overlays;
        }
    );
  in {
    nixosConfigurations = {
      darkstar = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {nixpkgs.overlays = overlays;}
          ./machines/darkstar
          ./modules/flatpak.nix
          # ./modules/appimage.nix
          nix-snapd.nixosModules.default
          ./modules/snap.nix
          {snap.enable = true;}
          home-manager.nixosModules.home-manager
          {
            users.users.rafael = {
              isNormalUser = true;
              group = "rafael";
            };
            users.groups.rafael = {};
          }
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.rafael = {
              imports = [
                ./modules/home.nix
                ./modules/nixos.nix
                ./modules/pkgs.nix
                ./modules/editorconfig.nix
                ./modules/yamllint.nix
                # ./modules/go.nix
                # ./modules/rust.nix
                ./modules/search.nix
                ./modules/tmux
                ./modules/neovim
                ./modules/git
                ./modules/gh
                ./modules/top
                ./modules/shell.nix
                ./modules/ssh
                ./modules/charm.nix
                # nix-index-database.hmModules.nix-index
              ];
            };
          }
        ];
      };
    };
    # darwinConfigurations = {
    #   darkmatter = darwin.lib.darwinSystem {
    #     system = "aarch64-darwin";
    #     modules = [
    #       {nixpkgs.overlays = overlays;}
    #       ./machines/darkmatter
    #       home-manager.darwinModules.home-manager
    #       {
    #         home-manager.useGlobalPkgs = true;
    #         home-manager.useUserPackages = false;
    #         home-manager.users.rafael = {
    #           #  programs.neovim.package = neovim-nightly.packages.aarch64-darwin.default;
    #           imports = [
    #             ./modules/home.nix
    #             ./modules/darwin
    #             ./modules/pkgs.nix
    #             ./modules/editorconfig.nix
    #             ./modules/yamllint.nix
    #             ./modules/go.nix
    #             ./modules/rust.nix
    #             ./modules/search.nix
    #             ./modules/ghostty
    #             ./modules/rio
    #             ./modules/tmux
    #             ./modules/neovim
    #             ./modules/git
    #             ./modules/gh
    #             ./modules/top
    #             ./modules/shell.nix
    #             ./modules/ssh
    #             ./modules/charm.nix
    #             ./modules/hammerspoon
    #             caarlos0-nur.homeManagerModules.default
    #             ./modules/yubikey.nix
    #             nix-index-database.hmModules.nix-index
    #           ];
    #         };
    #       }
    #     ];
    #   };
    # };
    # media = nixpkgs.lib.nixosSystem {
    #   system = "x86_64-linux";
    #   modules = [
    #     {nixpkgs.overlays = overlays;}
    #     {
    #       nixpkgs.config.permittedInsecurePackages = [
    #         "dotnet-sdk-6.0.428"
    #         "aspnetcore-runtime-6.0.36"
    #       ];
    #     }
    #     ./machines/media
    #     home-manager.nixosModules.home-manager
    #     {
    #       home-manager.useGlobalPkgs = true;
    #       home-manager.useUserPackages = true;
    #       home-manager.users.rafael = {
    #         imports = [
    #           ./modules/home.nix
    #           ./modules/nixos.nix
    #           ./modules/shell.nix
    #         ];
    #       };
    #     }
    #   ];
    # };

    devShells = forAllSystems (
      system: let
        pkgs = nixpkgsFor.${system};
      in {
        default = pkgs.mkShellNoCC {
          buildInputs = with pkgs; [
            (writeScriptBin "dot-clean" ''
              nix-collect-garbage -d --delete-older-than 30d
            '')
            # (writeScriptBin "dot-release" ''
            #   tag="$(date +%Y).$(expr $(date +%m) + 0).$(expr $(date +%d) + 0)"
            #   git tag -m "$tag" "$tag"
            #   git push --tags
            #   goreleaser release --clean
            # '')
            # (writeScriptBin "dot-sync" ''
            #   git pull --rebase origin main
            #   nix flake update
            #   dot-clean
            #   dot-apply
            # '')
            # (writeScriptBin "dot-apply" ''
            #   if test $(uname -s) == "Linux"; then
            #     sudo nixos-rebuild switch --flake .#
            #   fi
            #   if test $(uname -s) == "Darwin"; then
            #     nix build "./#darwinConfigurations.$(hostname | cut -f1 -d'.').system"
            #     ./result/sw/bin/darwin-rebuild switch --flake .
            #   fi
            # '')
          ];
        };
      }
    );
  };
}
