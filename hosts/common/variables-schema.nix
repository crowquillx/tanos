{ lib, ... }:
{
  options.tanos.variables = lib.mkOption {
    type = lib.types.attrs;
    default = { };
    description = "Host-scoped variables loaded from hosts/<host>/variables.nix.";
  };
}
