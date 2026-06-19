# sops-nix Setup

This repo uses `sops-nix` with an age key stored on each target machine.
A `home/security/ssh-key.nix` HM module materializes the user's SSH key from
sops into `~/.ssh/` for hosts that opt in via `security.sops.sshKey.enable`.

## 1) Generate host age key (if missing)

```bash
sudo mkdir -p /var/lib/sops-nix
sudo nix shell nixpkgs#age --command age-keygen -o /var/lib/sops-nix/key.txt
sudo chmod 600 /var/lib/sops-nix/key.txt
sudo cat /var/lib/sops-nix/key.txt | grep "^# public key:" | cut -d' ' -f4
```

Copy that public key into `.sops.yaml` recipients.

## 2) Create encrypted host secret file

```bash
mkdir -p secrets
sops secrets/<host>.yaml
```

Example:

```bash
sops secrets/tanvm.yaml
```

To store the user's SSH key in sops, add the key as a sops secret. The
example below is what the host module expects when
`security.sops.sshKey.enable = true`:

```yaml
ssh_key: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  ...
  -----END OPENSSH PRIVATE KEY-----
ssh_key_pub: ssh-rsa AAAA... tan@tandesk
```

## 3) Point host variables to that file

In `hosts/<host>/variables.nix`, set:

```nix
security.sops = {
  enable = true;
  defaultSopsFile = ../../secrets/<host>.yaml;
  ageKeyFile = "/var/lib/sops-nix/key.txt";
  sshKey = {
    enable = true;
    name = "ssh_key";
    pubName = "ssh_key_pub";
  };
};
```

## 4) Apply config

```bash
sudo ./install/bootstrap.sh <host>
```

or:

```bash
tcli rebuild switch <host>
```

## Optional: passphrase-protected age key ("password" option)

To make `sops` CLI usage work via a passphrase (independent of any PGP
Yubikey), generate a passphrase-protected age key and add it as a second
key group in `.sops.yaml`:

```bash
nix shell nixpkgs#age --command age-keygen -p -o ~/.config/sops/age-passphrase.key
chmod 600 ~/.config/sops/age-passphrase.key
age-keygen -y ~/.config/sops/age-passphrase.key
```

Then in `.sops.yaml`, add a second `age` key group containing the new
public key. sops will encrypt to both groups; you can decrypt with either.

Note: `sops-nix`'s runtime `sops.age.keyFile` does not prompt for a
passphrase at boot, so a passphrase-protected age key only works for
manual `sops` CLI usage, not for runtime secret materialization.

## Optional: Yubikey PGP ("yubikey" option)

To make sops decryptable via a PGP key on a Yubikey:

1. Install `gnupg` and `yubikey-manager` (already in `users.extraPackages`
   on hosts that opt in to sops).
2. Generate a PGP key on an offline machine and move the *public* key to
   this host, OR generate the key directly on the Yubikey via:
   ```bash
   ykman openpgp keys reset
   gpg --card-edit
   # inside the card-edit prompt: generate, save
   ```
3. Find the fingerprint:
   ```bash
   gpg --list-secret-keys --keyid-format=long
   ```
4. Add a `pgp` key group to `.sops.yaml` with the fingerprint.
5. In the host's `variables.nix`, set:
   ```nix
   security.sops.gnupgHome = "/var/lib/sops-nix/gnupg";
   ```
6. Make sure the Yubikey is plugged in at boot. `sops-install-secrets`
   will use the PGP key (or fall back to the age key file if the
   Yubikey is absent).

## Notes

- Bootstrap auto-creates `/var/lib/sops-nix/key.txt` if missing.
- Keep `.sops.yaml` in sync with all host public keys that need decryption.
- The HM module `modules/home/security/ssh-key.nix` is only active when
  both `security.sops.enable` and `security.sops.sshKey.enable` are true.
  It enforces `~/.ssh` mode 0700 and symlinks the materialized secrets
  into place.
