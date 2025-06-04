{...}: {
  programs.lsd = {
    enable = true;
    # The option definition `programs.lsd.enableAliases' in `/nix/store/jll2rfiwnnscihf1gk2fn52lwl959b85-source/modules/lsd.nix' no longer has any effect; please remove it.
    #    'programs.lsd.enableAliases' has been deprecated and replaced with integration
    #    options per shell, for example, 'programs.lsd.enableBashIntegration'.

    #    Note, the default for these options is 'true' so if you want to enable the
    #    aliases you can simply remove 'programs.lsd.enableAliases' from your
    #    configuration.
    # enableAliases = true;
  };
}
