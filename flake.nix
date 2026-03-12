{
  description = "Minimal multi-host NixOS + Home Manager setup with Niri, Noctalia, and sops-nix";

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
      niriOverlay = lib.attrByPath [ "niri" "overlays" "niri" ] null inputs;
      niriNixosModule = lib.attrByPath [ "niri" "nixosModules" "niri" ] null inputs;
      niriHmConfigModule = lib.attrByPath [ "niri" "homeModules" "config" ] null inputs;
      noctaliaHmModule = lib.attrByPath [ "noctalia" "homeModules" "default" ] null inputs;
      hostPlatforms = {
        tandesk = "x86_64-linux";
        tanvm = "x86_64-linux";
        tanlappy = "x86_64-linux";
      };

      mkHost = hostName: hostPlatform:
        let
          hostPath = ./hosts + "/${hostName}";
          vars = import (hostPath + "/variables.nix");
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

      mkHome = hostName: hostPlatform:
        let
          hostPath = ./hosts + "/${hostName}";
          vars = import (hostPath + "/variables.nix");
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
      homeConfigurations = lib.mapAttrs mkHome hostPlatforms;
    };
}
