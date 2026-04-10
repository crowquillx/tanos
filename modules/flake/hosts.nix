{ self, inputs, ... }:
let
  lib = inputs.nixpkgs.lib;
  combined = import ../combined/stacks.nix;
  noctaliaHmModule = lib.attrByPath [ "noctalia" "homeModules" "default" ] null inputs;
  hostPlatforms = {
    tandesk = "x86_64-linux";
    tanvm = "x86_64-linux";
    tanlappy = "x86_64-linux";
  };

  hostVars = lib.mapAttrs (hostName: _: import ../../hosts/${hostName}/variables.nix) hostPlatforms;

  getNiriInput =
    vars:
    let
      useWip = lib.attrByPath [ "desktop" "niri" "useWip" ] false vars;
    in
    if useWip then inputs."niri-wip" else inputs.niri;

  getNiriOverlay = vars: lib.attrByPath [ "overlays" "niri" ] null (getNiriInput vars);
  getNiriNixosModule = vars: lib.attrByPath [ "nixosModules" "niri" ] null (getNiriInput vars);
  getNiriHmConfigModule = vars: lib.attrByPath [ "homeModules" "config" ] null (getNiriInput vars);

  millenniumEnabled =
    vars: lib.attrByPath [ "features" "gaming" "steam" "millennium" "enable" ] false vars;

  mkHost =
    hostName: hostPlatform:
    let
      vars = hostVars.${hostName};
      niriOverlay = getNiriOverlay vars;
      niriNixosModule = getNiriNixosModule vars;
    in
    lib.nixosSystem {
      specialArgs = {
        inherit
          self
          inputs
          vars
          hostName
          combined
          ;
      };
      modules = [
        {
          nixpkgs.hostPlatform = hostPlatform;
          nixpkgs.overlays =
            lib.optionals (niriOverlay != null) [ niriOverlay ]
            ++ lib.optional (millenniumEnabled vars) inputs.millennium.overlays.default;
        }
        inputs.determinate.nixosModules.default
        inputs.home-manager.nixosModules.home-manager
        inputs.nix-flatpak.nixosModules.nix-flatpak
        inputs.sops-nix.nixosModules.sops
        inputs.stylix.nixosModules.stylix
        inputs.lanzaboote.nixosModules.lanzaboote
        self.nixosModules.${hostName}
      ]
      ++ lib.optionals (niriNixosModule != null) [ niriNixosModule ];
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
      niriOverlay = getNiriOverlay vars;
      niriHmConfigModule = getNiriHmConfigModule vars;
      primaryUser = lib.attrByPath [ "users" "primary" ] "tan" vars;
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        system = hostPlatform;
        config.allowUnfree = true;
        overlays =
          lib.optionals (niriOverlay != null) [ niriOverlay ]
          ++ lib.optional (millenniumEnabled vars) inputs.millennium.overlays.default;
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
        self.homeModules.${primaryUser}
        {
          home.username = primaryUser;
          home.homeDirectory = "/home/${primaryUser}";
        }
      ]
      ++ lib.optionals (niriHmConfigModule != null) [ niriHmConfigModule ]
      ++ lib.optionals (noctaliaHmModule != null) [ noctaliaHmModule ];
    };
in
{
  systems = [ "x86_64-linux" ];

  flake = {
    nixosModules = {
      tandesk = import ../../hosts/tandesk/default.nix;
      tanvm = import ../../hosts/tanvm/default.nix;
      tanlappy = import ../../hosts/tanlappy/default.nix;
    };

    homeModules = {
      tan = import ../../users/tan/home.nix;
    };

    nixosConfigurations = lib.mapAttrs mkHost hostPlatforms;
    ciNixosConfigurations = lib.mapAttrs mkCiHost hostPlatforms;
    homeConfigurations = lib.mapAttrs mkHome hostPlatforms;
  };
}
