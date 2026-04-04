{ lib, pkgs, vars ? { }, config, ... }:
let
  get = path: default: lib.attrByPath path default vars;
  desktopEnabled = get [ "desktop" "enable" ] true;
  compositor = get [ "desktop" "compositor" ] "niri";
  noctaliaEnabled = get [ "desktop" "noctalia" "enable" ] (desktopEnabled && compositor == "niri");
  secrets = get [ "desktop" "noctalia" "assistantPanel" "secrets" ] { };
  immutableSettingsFile = lib.attrByPath [ "xdg" "configFile" "noctalia/settings.json" "source" ] null config;

  mkSecretPath = name:
    if lib.isString name && name != "" then "/run/secrets/${name}" else null;

  googleApiKeyPath = mkSecretPath (secrets.googleApiKey or "");
  openaiCompatibleApiKeyPath = mkSecretPath (secrets.openaiCompatibleApiKey or "");
  deeplApiKeyPath = mkSecretPath (secrets.deeplApiKey or "");

  exportSecret = envName: secretPath:
    lib.optionalString (secretPath != null) ''
      if [ -r ${lib.escapeShellArg secretPath} ]; then
        export ${envName}="$(${pkgs.coreutils}/bin/cat ${lib.escapeShellArg secretPath})"
      fi
    '';

  noctaliaCommandWrapper = pkgs.writeShellScriptBin "tanos-noctalia-shell" ''
    set -eu

    ${lib.optionalString (immutableSettingsFile != null) ''
      export NOCTALIA_SETTINGS_FILE=${lib.escapeShellArg (toString immutableSettingsFile)}
    ''}

    ${exportSecret "NOCTALIA_AP_GOOGLE_API_KEY" googleApiKeyPath}
    ${exportSecret "NOCTALIA_AP_OPENAI_COMPATIBLE_API_KEY" openaiCompatibleApiKeyPath}
    ${exportSecret "NOCTALIA_AP_DEEPL_API_KEY" deeplApiKeyPath}

    exec noctalia-shell "$@"
  '';
in
{
  config = lib.mkIf noctaliaEnabled {
    home.packages = [ noctaliaCommandWrapper ];
  };
}
