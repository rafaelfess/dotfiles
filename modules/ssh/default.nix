{config, ...}: {
  programs.ssh = {
    enable = true;
    # includes = ["~/.ssh/config.local"];
    serverAliveInterval = 60;
    matchBlocks = {
      "*" = {
        identityFile = "~/.ssh/com_bleesoft_r__dev_id";
        # https://ghostty.org/docs/help/terminfo
        setEnv = {
          TERM = "xterm-256color";
        };
        sendEnv = [
          "COLORTERM"
          # "TERM"
        ];
        extraOptions = {
          IgnoreUnknown = "UseKeychain";
          UseKeyChain = "yes";
          AddKeysToAgent = "yes";
        };
      };
      "github.com" = {
        serverAliveInterval = 0;
        identityFile = "~/.ssh/com_bleesoft_r__dev_id";
        extraOptions = {
          ControlMaster = "auto"; # Enables SSH connection sharing/multiplexing
          ControlPath = "~/.ssh/github.sock";
          ControlPersist = "5m";
          AddKeysToAgent = "yes";
        };
      };
      "gitlab.com" = {
        serverAliveInterval = 0;
        identityFile = "~/.ssh/com_bleesoft_r__dev_id";
        extraOptions = {
          ControlMaster = "auto";
          ControlPath = "~/.ssh/gitlab.sock";
          ControlPersist = "5m";
        };
      };
      "codeberg.org" = {
        serverAliveInterval = 0;
        identityFile = "~/.ssh/com_bleesoft_r__dev_id";
        extraOptions = {
          ControlMaster = "auto";
          ControlPath = "~/.ssh/codeberg.sock";
          ControlPersist = "5m";
        };
      };
      # "localhost" = {
      #   extraOptions = {
      #     UserKnownHostsFile = "/dev/null";
      #     StrictHostKeyChecking = "false";
      #   };
      # };
      # "dev" = {
      #   forwardAgent = true;
      #   remoteForwards = [
      #     {
      #       # pbcopy
      #       bind.port = 2224;
      #       host.address = "127.0.0.1";
      #       host.port = 2224;
      #     }
      #     {
      #       # pbpaste
      #       bind.port = 2225;
      #       host.address = "127.0.0.1";
      #       host.port = 2225;
      #     }
      #     {
      #       # xdg-open-svc
      #       bind.port = 2226;
      #       host.address = "127.0.0.1";
      #       host.port = 2226;
      #     }
      #   ];
      #   extraOptions = {
      #     RequestTTY = "true";
      #     RemoteCommand = "tmux new -A -s default";
      #   };
      # };
      # "aur.archlinux.org" = {
      #   identityFile = "~/.ssh/aur";
      # };
    };
  };

  # home.file.".ssh/rc".source = config.lib.file.mkOutOfStoreSymlink ./rc;
}
