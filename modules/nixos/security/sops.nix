{
  lib,
  vars ? { },
  ...
}:
let
  get = path: default: lib.attrByPath path default vars;
  enabled = get [ "security" "sops" "enable" ] true;
  defaultSopsFile = get [ "security" "sops" "defaultSopsFile" ] null;
  ageKeyFile = get [ "security" "sops" "ageKeyFile" ] "/var/lib/sops-nix/key.txt";
  gnupgHome = get [ "security" "sops" "gnupgHome" ] null;
  primaryUser = get [ "users" "primary" ] "tan";
  sshKey = {
    enable = get [ "security" "sops" "sshKey" "enable" ] false;
    name = get [ "security" "sops" "sshKey" "name" ] "ssh_key";
    pubName = get [ "security" "sops" "sshKey" "pubName" ] "ssh_key_pub";
    privMode = get [ "security" "sops" "sshKey" "privateMode" ] "0600";
    pubMode = get [ "security" "sops" "sshKey" "publicMode" ] "0644";
  };
in
{
  config = lib.mkMerge [
    (lib.optionalAttrs (defaultSopsFile != null) {
      sops.defaultSopsFile = defaultSopsFile;
    })
    (lib.mkIf enabled {
      sops = {
        age = {
          keyFile = ageKeyFile;
          # We intentionally do not use host openssh keys for sops.
          # The host's openssh host key is unrelated to user secrets.
          sshKeyPaths = lib.mkForce [ ];
        };
        gnupg = {
          # sops-nix defaults gnupg.sshKeyPaths to the host's RSA ssh host
          # key. Loading it as a GPG identity fails decryption because the
          # host key is not a sops recipient. Disable the auto-import.
          sshKeyPaths = lib.mkForce [ ];
        };
        # Decrypt at every boot via a systemd unit so /run/secrets survives
        # across reboots. Without this, secrets are only materialized at
        # nixos-rebuild switch time, which is not enough for a workstation
        # that boots daily.
        useSystemdActivation = true;
        validateSopsFiles = false;
      };
    })
    (lib.optionalAttrs (gnupgHome != null) {
      # When set, sops-nix will look here for GnuPG keys (PGP/Yubikey).
      # Pair with a pgp recipient in .sops.yaml.
      sops.gnupg.home = gnupgHome;
    })
    (lib.mkIf (enabled && sshKey.enable) {
      sops.secrets.${sshKey.name} = {
        owner = primaryUser;
        group = "users";
        mode = sshKey.privMode;
        path = "/run/secrets/${sshKey.name}";
      };
      sops.secrets.${sshKey.pubName} = {
        owner = primaryUser;
        group = "users";
        mode = sshKey.pubMode;
        path = "/run/secrets/${sshKey.pubName}";
      };
    })
  ];
}
