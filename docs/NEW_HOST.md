# Add A New Host

## 1) Copy an existing host profile

Use `tanvm` as a starting point unless you need laptop defaults.

```bash
cp -r hosts/tanvm hosts/<newhost>
```

## 2) Update host variables

Edit `hosts/<newhost>/variables.nix` and at minimum set:

- `host.name = "<newhost>"`
- `host.isVm = true|false`
- desktop, graphics, feature toggles for that machine
- `security.sops.defaultSopsFile = ../../secrets/<newhost>.yaml` (if using sops)

Detailed variable reference: `docs/VARIABLES.md`.

## 3) Provide hardware configuration

Option A (recommended): let bootstrap generate it.

```bash
sudo ./install/bootstrap.sh <newhost> --update-hardware
```

Option B: manually generate and place `hosts/<newhost>/hardware-configuration.nix`.

## 4) Register host in flake outputs

Add `<newhost>` in `flake.nix` under `hostPlatforms` so both outputs are generated:

- `nixosConfigurations.<newhost>`
- `homeConfigurations.<newhost>`

## 5) Build and switch

```bash
sudo ./install/bootstrap.sh <newhost>
```

or after initial bootstrap:

```bash
tcli rebuild switch <newhost>
```

## 6) Verify

- system build completes without eval errors
- user session comes up as expected
- Home Manager activation applies for the primary user
