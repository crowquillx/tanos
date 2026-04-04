{
  enable = true;
  command = "tanos-noctalia-shell";
  systemd.enable = false;
  assistantPanel.secrets = {
    googleApiKey = "noctalia-ap-google-api-key";
  };
  settings = import ./settings.nix;
  colors = import ./colors.nix;
  plugins = import ./plugins.nix;
  pluginSettings = import ./plugin-settings.nix;
  userTemplates = import ./user-templates.nix;
}
