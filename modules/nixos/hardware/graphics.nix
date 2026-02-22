{ lib, pkgs, config, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;

  allowedProfiles = [ "auto" "none" "amd" "intel" "nvidia" "vm" ];
  hostIsVm = get [ "host" "isVm" ] false;
  profileRaw = get [ "graphics" "profile" ] "auto";
  profile =
    if profileRaw == "auto"
    then if hostIsVm then "vm" else "none"
    else profileRaw;

  extraPackageNames = get [ "graphics" "extraPackages" ] [ ];
  resolvePkg = name: lib.attrByPath (lib.splitString "." name) null pkgs;
  missingPackageNames = lib.filter (name: resolvePkg name == null) extraPackageNames;
  resolvedExtraPackages = lib.filter (pkg: pkg != null) (map resolvePkg extraPackageNames);

  nvidiaModesettingEnable = get [ "graphics" "nvidia" "modesetting" "enable" ] true;
  nvidiaPowerManagementEnable = get [ "graphics" "nvidia" "powerManagement" "enable" ] false;
  nvidiaOpenEnable = get [ "graphics" "nvidia" "open" ] false;
in
{
  assertions = [
    {
      assertion = builtins.elem profileRaw allowedProfiles;
      message = ''
        Invalid graphics.profile "${toString profileRaw}".
        Allowed values: ${lib.concatStringsSep ", " allowedProfiles}
      '';
    }
    {
      assertion = missingPackageNames == [ ];
      message = "Unknown graphics.extraPackages entries: ${lib.concatStringsSep ", " missingPackageNames}";
    }
  ];

  config = lib.mkMerge [
    (lib.mkIf (profile != "none") {
      hardware.graphics.enable = lib.mkDefault true;
    })

    (lib.mkIf (resolvedExtraPackages != [ ]) {
      hardware.graphics.extraPackages = resolvedExtraPackages;
    })

    (lib.mkIf (profile == "amd") {
      services.xserver.videoDrivers = [ "amdgpu" ];
    })

    (lib.mkIf (profile == "intel") {
      services.xserver.videoDrivers = [ "modesetting" ];
    })

    (lib.mkIf (profile == "nvidia") {
      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {
        modesetting.enable = nvidiaModesettingEnable;
        powerManagement.enable = nvidiaPowerManagementEnable;
        open = nvidiaOpenEnable;
      };
    })

    (lib.mkIf (profile == "vm") {
      environment.sessionVariables = {
        WLR_RENDERER_ALLOW_SOFTWARE = "1";
        LIBGL_ALWAYS_SOFTWARE = "1";
      };
    })
  ];
}
