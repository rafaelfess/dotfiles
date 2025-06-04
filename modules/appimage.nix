{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    appimage = {
      enable = lib.mkEnableOption "AppImage support";
      storageDir = lib.mkOption {
        type = lib.types.str;
        default = ".local/share/applications";
        description = "Directory to store AppImage files, following XDG Base Directory Specification";
      };
      apps = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "Name of the AppImage application";
            };
            url = lib.mkOption {
              type = lib.types.str;
              description = "URL to download the AppImage";
            };
            hash = lib.mkOption {
              type = lib.types.str;
              description = "SHA256 hash of the AppImage file";
            };
          };
        });
        default = {};
        description = "AppImages to install";
      };
    };
  };

  config = lib.mkIf config.appimage.enable {
    # Configure default AppImages
    appimage.apps = {
      obsidian = {
        name = "obsidian";
        url = "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.5.3/Obsidian-1.5.3.AppImage";
        hash = "sha256-IuTzI1N0IXEM7eZdni1kU6ldu7X/iq4dXIaHIOq0Zcs=";
      };
      onlyoffice = {
        name = "onlyoffice";
        url = "https://github.com/ONLYOFFICE/DesktopEditors/releases/download/v7.5.1/ONLYOFFICE-DesktopEditors.AppImage";
        hash = "sha256-zWlGKjt7W7YWGzRfxdckL06+NPBjWVVi/2uZtj685y0=";
      };
    };

    # Create AppImage storage directory and download configured AppImages
    system.activationScripts.appimage-directory = {
      text = let
        users = lib.filterAttrs (_: u: u.isNormalUser or false) config.users.users;
        mkAppImageDir = username: user: ''
          # Create directory
          mkdir -p "${user.home}/${config.appimage.storageDir}"
          chown ${username}:${user.group} "${user.home}/${config.appimage.storageDir}"

          # Download and set up AppImages
          ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: app: ''
              # Download ${app.name} AppImage
              ${pkgs.curl}/bin/curl -L -o "${user.home}/${config.appimage.storageDir}/${app.name}.AppImage" "${app.url}"
              # Make executable
              chmod +x "${user.home}/${config.appimage.storageDir}/${app.name}.AppImage"
              # Set ownership
              chown ${username}:${user.group} "${user.home}/${config.appimage.storageDir}/${app.name}.AppImage"

              # Create desktop entry
              cat > "${user.home}/.local/share/applications/${app.name}.desktop" << EOF
              [Desktop Entry]
              Type=Application
              Name=${
                if name == "obsidian"
                then "Obsidian"
                else if name == "onlyoffice"
                then "ONLYOFFICE"
                else app.name
              }
              Exec=${user.home}/${config.appimage.storageDir}/${app.name}.AppImage
              Icon=${
                if name == "obsidian"
                then "obsidian"
                else if name == "onlyoffice"
                then "onlyoffice-desktopeditors"
                else app.name
              }
              Categories=${
                if name == "obsidian"
                then "Office;TextEditor;"
                else if name == "onlyoffice"
                then "Office;WordProcessor;Spreadsheet;Presentation;"
                else "Utility;"
              }
              Comment=${
                if name == "obsidian"
                then "Knowledge base markdown editor"
                else if name == "onlyoffice"
                then "Office suite for documents, spreadsheets and presentations"
                else "AppImage application"
              }
              MimeType=${
                if name == "obsidian"
                then "text/markdown;"
                else if name == "onlyoffice"
                then "application/vnd.oasis.opendocument.text;application/vnd.oasis.opendocument.spreadsheet;application/vnd.oasis.opendocument.presentation;"
                else ""
              }
              EOF

              # Set ownership and permissions for desktop entry
              chown ${username}:${user.group} "${user.home}/.local/share/applications/${app.name}.desktop"
              chmod 644 "${user.home}/.local/share/applications/${app.name}.desktop"

              # Update desktop database to refresh GNOME's application list
              ${pkgs.desktop-file-utils}/bin/update-desktop-database "${user.home}/.local/share/applications"
            '')
            config.appimage.apps)}
        '';
      in
        lib.concatStrings (lib.mapAttrsToList mkAppImageDir users);
      deps = [];
    };

    # Add required system packages for AppImage support
    environment.systemPackages = with pkgs; [
      # Required for downloading AppImages
      curl
      # Required for AppImage execution
      fuse
      # AppImage integration tool
      appimage-run
      # Required for desktop integration
      desktop-file-utils
      hicolor-icon-theme
      shared-mime-info
    ];

    # Allow FUSE access (required for AppImage)
    boot.supportedFilesystems = ["fuse"];
    boot.kernelModules = ["fuse"];
  };
}
