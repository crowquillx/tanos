{
  description = "Minimal multi-host NixOS + Home Manager setup with Niri/KDE, Noctalia, and sops-nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
    };

    niri-wip = {
      url = "github:sodiboo/niri-flake";
      # Track niri-wm/niri PR head while keeping niri-flake wiring/overlay shape.
      # Branch/ref can be changed later if a different WIP target is desired.
      inputs."niri-unstable".url = "github:niri-wm/niri?ref=pull/3483/head";
      inputs."niri-stable".url = "github:niri-wm/niri?ref=pull/3483/head";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium2nix = {
      url = "github:FKouhai/helium2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    danksearch = {
      url = "github:AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
      noctaliaHmModule = lib.attrByPath [ "noctalia" "homeModules" "default" ] null inputs;
      hostPlatforms = {
        tandesk = "x86_64-linux";
        tanvm = "x86_64-linux";
        tanlappy = "x86_64-linux";
      };
      getNiriInput = vars:
        let
          useWip = lib.attrByPath [ "desktop" "niri" "useWip" ] false vars;
        in
        if useWip then inputs."niri-wip" else inputs.niri;
      getNiriOverlay = vars: lib.attrByPath [ "overlays" "niri" ] null (getNiriInput vars);
      getNiriNixosModule = vars: lib.attrByPath [ "nixosModules" "niri" ] null (getNiriInput vars);
      getNiriHmConfigModule = vars: lib.attrByPath [ "homeModules" "config" ] null (getNiriInput vars);

      mkHost = hostName: hostPlatform:
        let
          hostPath = ./hosts + "/${hostName}";
          vars = import (hostPath + "/variables.nix");
          niriOverlay = getNiriOverlay vars;
          niriNixosModule = getNiriNixosModule vars;
        in
        lib.nixosSystem {
          specialArgs = {
            inherit inputs vars hostName;
          };
          modules = [
            {
              nixpkgs.hostPlatform = hostPlatform;
              nixpkgs.overlays = lib.optionals (niriOverlay != null) [ niriOverlay ];
            }
            inputs.home-manager.nixosModules.home-manager
            inputs.sops-nix.nixosModules.sops
            inputs.stylix.nixosModules.stylix
            (hostPath + "/default.nix")
          ]
          ++ lib.optionals (niriNixosModule != null) [ niriNixosModule ];
        };

      mkCiHost = hostName: hostPlatform:
        (mkHost hostName hostPlatform).extendModules {
          modules = [
            ({ lib, ... }: {
              # CI-only fallback so placeholder hardware files still evaluate.
              fileSystems."/" = lib.mkDefault {
                device = "none";
                fsType = "tmpfs";
              };
            })
          ];
        };

      mkHome = hostName: hostPlatform:
        let
          hostPath = ./hosts + "/${hostName}";
          vars = import (hostPath + "/variables.nix");
          niriOverlay = getNiriOverlay vars;
          niriHmConfigModule = getNiriHmConfigModule vars;
          primaryUser = lib.attrByPath [ "users" "primary" ] "tan" vars;
          userHomePath = ./users + "/${primaryUser}/home.nix";
        in
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = hostPlatform;
            config.allowUnfree = true;
            overlays = lib.optionals (niriOverlay != null) [ niriOverlay ];
          };
          extraSpecialArgs = { inherit vars inputs; };
          modules = [
            userHomePath
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
      nixosConfigurations = lib.mapAttrs mkHost hostPlatforms;
      ciNixosConfigurations = lib.mapAttrs mkCiHost hostPlatforms;
      homeConfigurations = lib.mapAttrs mkHome hostPlatforms;
    };
}
