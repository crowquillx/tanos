{
  description = "Minimal multi-host NixOS + Home Manager setup with niri, switchable shell, and sops-nix";

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

    niri-naxdy = {
      url = "github:Naxdy/niri";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri-upstream = {
      url = "github:YaLTeR/niri";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      lib = nixpkgs.lib;

      mkHost = hostName: hostPlatform:
        let
          hostPath = ./hosts + "/${hostName}";
          vars = import (hostPath + "/variables.nix");
          niriSource = lib.attrByPath [ "desktop" "niri" "source" ] "naxdy" vars;
          niriModule =
            if niriSource == "upstream"
            then (inputs.niri-upstream.nixosModules.niri or { })
            else (inputs.niri-naxdy.nixosModules.niri or { });
        in
        lib.nixosSystem {
          specialArgs = {
            inherit inputs vars hostName;
          };
          modules = [
            { nixpkgs.hostPlatform = hostPlatform; }
            niriModule
            inputs.home-manager.nixosModules.home-manager
            inputs.sops-nix.nixosModules.sops
            (hostPath + "/default.nix")
          ];
        };
    in
    {
      nixosConfigurations = {
        tandesk = mkHost "tandesk" "x86_64-linux";
        tanvm = mkHost "tanvm" "x86_64-linux";
      };
    };
}
