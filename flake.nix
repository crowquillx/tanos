{
  description = "Minimal multi-host NixOS + Home Manager setup with Hyprland + illogical-flake and sops-nix";

  nixConfig = {
    extra-substituters = [ "https://hyprland.cachix.org" ];
    extra-trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

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

    hyprland = {
      url = "github:hyprwm/Hyprland?submodules=1";
    };

    illogical = {
      url = "github:soymou/illogical-flake";
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
      hyprlandNixosModule = lib.attrByPath [ "hyprland" "nixosModules" "default" ] null inputs;
      hyprlandHmModule = lib.attrByPath [ "hyprland" "homeManagerModules" "default" ] null inputs;
      illogicalHmModule = lib.attrByPath [ "illogical" "homeManagerModules" "default" ] null inputs;
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
            }
            inputs.home-manager.nixosModules.home-manager
            inputs.sops-nix.nixosModules.sops
            inputs.stylix.nixosModules.stylix
            (hostPath + "/default.nix")
          ]
          ++ lib.optionals (hyprlandNixosModule != null) [ hyprlandNixosModule ];
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
          };
          extraSpecialArgs = { inherit vars inputs; };
          modules = [
            userHomePath
            {
              home.username = primaryUser;
              home.homeDirectory = "/home/${primaryUser}";
            }
          ]
          ++ lib.optionals (hyprlandHmModule != null) [ hyprlandHmModule ]
          ++ lib.optionals (illogicalHmModule != null) [ illogicalHmModule ];
        };
    in
    {
      nixosConfigurations = lib.mapAttrs mkHost hostPlatforms;
      homeConfigurations = lib.mapAttrs mkHome hostPlatforms;
    };
}
