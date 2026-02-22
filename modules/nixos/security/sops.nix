{ lib, vars ? { }, ... }:
let
  get = path: default: lib.attrByPath path default vars;
  enabled = get [ "security" "sops" "enable" ] true;
  defaultSopsFile = get [ "security" "sops" "defaultSopsFile" ] null;
  ageKeyFile = get [ "security" "sops" "ageKeyFile" ] "/var/lib/sops-nix/key.txt";
in
{
  config = lib.mkIf enabled (
    {
      sops = {
        age.keyFile = ageKeyFile;
        validateSopsFiles = false;
      };
    }
    // lib.optionalAttrs (defaultSopsFile != null) {
      sops.defaultSopsFile = defaultSopsFile;
    }
  );
}
