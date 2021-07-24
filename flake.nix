{
  description = "HexF's dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-21.05";
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-21.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, home-manager, nixpkgs }@inputs: 
    {  

      system.configurationRevision =
        if self ? rev
        then self.rev
        else throw "Refusing to build from a dirty Git tree!";
        
      nixosConfigurations = {
        snowflake = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [ 
            ./systems/common/base.nix
            ./systems/common/efi.nix
            ./systems/common/desktop.nix
            ./systems/snowflake-hardware.nix
            ./systems/snowflake.nix

            home-manager.nixosModules.home-manager rec {

              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.users.thobson = import ./users/thobson/home.nix "snowflake";
            }

          ];
        };

        hydroxide = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            ./systems/common/base.nix
            ./systems/common/bios.nix
            ./systems/common/server.nix
            ./systems/hydroxide-hardware.nix
            ./systems/hydroxide.nix
          ];
        };

        frostbite = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            ./systems/common/base.nix
            ./systems/common/efi.nix
            ./systems/common/desktop.nix
            ./systems/common/wireless.nix
            ./systems/frostbite-hardware.nix
            ./systems/frostbite.nix

            home-manager.nixosModules.home-manager rec {

              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.users.thobson = import ./users/thobson/home.nix "frostbite";
            }
          ];

        };
      };


      hydraJobs = {
        hydroxide = self.nixosConfigurations.hydroxide.config.system.build.toplevel;
        snowflake = self.nixosConfigurations.snowflake.config.system.build.toplevel;
      };
    };
}
