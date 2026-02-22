# sops-nix Setup

This repo uses `sops-nix` with an age key stored on each target machine.

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

## 3) Point host variables to that file

In `hosts/<host>/variables.nix`, set:

```nix
security.sops = {
  enable = true;
  defaultSopsFile = ../../secrets/<host>.yaml;
  ageKeyFile = "/var/lib/sops-nix/key.txt";
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

## Notes

- Bootstrap auto-creates `/var/lib/sops-nix/key.txt` if missing.
- Keep `.sops.yaml` in sync with all host public keys that need decryption.
