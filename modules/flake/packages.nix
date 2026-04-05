{ inputs, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    let
      lib = pkgs.lib;
      zenPkg = lib.attrByPath [ "packages" system "default" ] null inputs.zen-browser;
      heliumPkg =
        let
          fromPackages = lib.attrByPath [ "packages" system "default" ] null inputs.helium2nix;
          fromLegacy = lib.attrByPath [ "defaultPackage" system ] null inputs.helium2nix;
        in
        if fromPackages != null then fromPackages else fromLegacy;
      wrappedNoctalia =
        if inputs ? wrapper-modules then
          inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
            inherit pkgs;
            settings = { };
          }
        else
          null;
      wrappedNiri =
        if inputs ? wrapper-modules then
          inputs.wrapper-modules.wrappers.niri.wrap {
            inherit pkgs;
            settings = { };
          }
        else
          null;
    in
    {
      packages = lib.filterAttrs (_: value: value != null) {
        tanos-zen = zenPkg;
        tanos-helium = heliumPkg;
        tanos-noctalia = wrappedNoctalia;
        tanos-niri = wrappedNiri;
      };
    };
}
