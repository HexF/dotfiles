{
  description = "HexF's dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-21.05";
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-21.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-master.url = "github:NixOS/nixpkgs?ref=master";
  };

  outputs = { self, home-manager, nixpkgs, ... }@inputs: 
    let
      overlay-master = final: prev: {
        master = (import inputs.nixpkgs-master {
          config.allowUnfree = true;
          system = "${prev.system}";
        });
      };
      overlayModule = {
        nixpkgs.overlays = [overlay-master];
      };
      userModules = systemName: [
        home-manager.nixosModules.home-manager rec {

          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit systemName;
            inherit inputs;
          };

          home-manager.users.thobson = ./users/thobson/home.nix;
      
        }

      ];
    in {  

      nixosConfigurations = {
        snowflake = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [ 
            ./systems/snowflake.nix
            overlayModule
          ] ++ (userModules "snowflake");
        };

        hydroxide = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            ./systems/hydroxide.nix
            overlayModule
          ];
        };

        frostbite = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./systems/frostbite.nix
            overlayModule
          ] ++ (userModules "frostbite");

        };
      };


      hydraJobs = {
        hydroxide = self.nixosConfigurations.hydroxide.config.system.build.toplevel;
        snowflake = self.nixosConfigurations.snowflake.config.system.build.toplevel;
        frostbite = self.nixosConfigurations.frostbite.config.system.build.toplevel;
      };
    };
}
