{ lib, config, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  isVm = get [ "host" "isVm" ] false;
  softwareRendering = get [ "desktop" "vm" "softwareRendering" "enable" ] isVm;
in
{
  config = lib.mkIf isVm {
    services.qemuGuest.enable = true;
    services.spice-vdagentd.enable = true;

    environment.sessionVariables = lib.mkIf softwareRendering {
      WLR_RENDERER_ALLOW_SOFTWARE = "1";
      LIBGL_ALWAYS_SOFTWARE = "1";
    };
  };
}
