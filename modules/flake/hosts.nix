{ self, inputs, ... }:
let
  lib = inputs.nixpkgs.lib;
  combined = import ../combined/stacks.nix;
  hosts = {
    tandesk = {
      system = "x86_64-linux";
      module = ../../hosts/tandesk/default.nix;
      variables = ../../hosts/tandesk/variables.nix;
    };
    tanvm = {
      system = "x86_64-linux";
      module = ../../hosts/tanvm/default.nix;
      variables = ../../hosts/tanvm/variables.nix;
    };
    tanlappy = {
      system = "x86_64-linux";
      module = ../../hosts/tanlappy/default.nix;
      variables = ../../hosts/tanlappy/variables.nix;
    };
  };
  users = {
    tan = ../../users/tan/home.nix;
  };
  noctaliaHmModule = lib.attrByPath [ "noctalia" "homeModules" "default" ] null inputs;
  hostPlatforms = lib.mapAttrs (_: spec: spec.system) hosts;
  hostVars = lib.mapAttrs (_: spec: import spec.variables) hosts;
  nixosHostModules = lib.mapAttrs (_: spec: import spec.module) hosts;
  homeUserModules = lib.mapAttrs (_: path: import path) users;

  niriOverlay = lib.attrByPath [ "niri" "overlays" "niri" ] null inputs;
  niriNixosModule = lib.attrByPath [ "niri" "nixosModules" "niri" ] null inputs;
  niriHmConfigModule = lib.attrByPath [ "niri" "homeModules" "config" ] null inputs;
  aioboto3NoCheckOverlay = final: prev: {
    python313Packages = prev.python313Packages.overrideScope (pyFinal: pyPrev: {
      aioboto3 = pyPrev.aioboto3.overridePythonAttrs (_: { doCheck = false; });
    });
    python3Packages = prev.python3Packages.overrideScope (pyFinal: pyPrev: {
      aioboto3 = pyPrev.aioboto3.overridePythonAttrs (_: { doCheck = false; });
    });
  };

  openldapNoCheckOverlay = final: prev: {
    openldap = prev.openldap.overrideAttrs (_: { doCheck = false; });
  };

  sharedOverlays =
    vars:
    lib.optionals (niriOverlay != null) [ niriOverlay ]
    ++ lib.optional (millenniumEnabled vars) inputs.millennium.overlays.default
    ++ [ aioboto3NoCheckOverlay ]
    ++ [ openldapNoCheckOverlay ];
  sharedHomeModules =
    vars:
    lib.optionals (niriHmConfigModule != null) [ niriHmConfigModule ]
    ++ lib.optionals (noctaliaHmModule != null) [ noctaliaHmModule ];

  millenniumEnabled =
    vars: lib.attrByPath [ "features" "gaming" "steam" "millennium" "enable" ] false vars;

  mkHost =
    hostName: hostPlatform:
    let
      vars = hostVars.${hostName};
      niriNixosModule' = niriNixosModule;
    in
    lib.nixosSystem {
      specialArgs = {
        inherit
          self
          inputs
          vars
          hostName
          homeUserModules
          combined
          ;
      };
      modules = [
        {
          nixpkgs.hostPlatform = hostPlatform;
          nixpkgs.overlays = sharedOverlays vars;
        }
        inputs.determinate.nixosModules.default
        inputs.home-manager.nixosModules.home-manager
        inputs.nix-flatpak.nixosModules.nix-flatpak
        inputs.sops-nix.nixosModules.sops
        inputs.stylix.nixosModules.stylix
        inputs.lanzaboote.nixosModules.lanzaboote
        nixosHostModules.${hostName}
      ]
      ++ lib.optionals (niriNixosModule' != null) [ niriNixosModule' ];
    };

  mkCiHost =
    hostName: hostPlatform:
    (mkHost hostName hostPlatform).extendModules {
      modules = [
        (
          { lib, ... }:
          {
            fileSystems."/" = lib.mkDefault {
              device = "none";
              fsType = "tmpfs";
            };
          }
        )
      ];
    };

  mkHome =
    hostName: hostPlatform:
    let
      vars = hostVars.${hostName};
      primaryUser = lib.attrByPath [ "users" "primary" ] "tan" vars;
      homeModule = lib.attrByPath [ primaryUser ] null homeUserModules;
    in
    assert homeModule != null;
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        system = hostPlatform;
        config.allowUnfree = true;
        overlays = sharedOverlays vars;
      };
      extraSpecialArgs = {
        inherit
          self
          vars
          inputs
          combined
          ;
      };
      modules = [
        homeModule
        {
          home.username = primaryUser;
          home.homeDirectory = "/home/${primaryUser}";
        }
      ]
      ++ sharedHomeModules vars;
    };
in
{
  systems = [ "x86_64-linux" ];

  flake = {
    nixosModules = nixosHostModules;

    homeModules = homeUserModules;

    nixosConfigurations = lib.mapAttrs mkHost hostPlatforms;
    ciNixosConfigurations = lib.mapAttrs mkCiHost hostPlatforms;
    homeConfigurations = lib.mapAttrs mkHome hostPlatforms;
  };
}
