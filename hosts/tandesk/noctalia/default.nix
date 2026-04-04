{
  enable = true;
  systemd.enable = true;
  settings = import ./settings.nix;
  colors = import ./colors.nix;
  plugins = import ./plugins.nix;
  pluginSettings = import ./plugin-settings.nix;
  userTemplates = import ./user-templates.nix;
}
