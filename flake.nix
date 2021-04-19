{
  description = "HexF's dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=6f9ac9eb8a37b562531ddd1d4d16e8c401447445";
    home-manager = {
      url = "github:nix-community/home-manager";
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

            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.thobson = import ./users/thobson/home.nix;
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
      };


      hydraJobs = {
        hydroxide = self.nixosConfigurations.hydroxide.config.system.build.toplevel;
        snowflake = self.nixosConfigurations.snowflake.config.system.build.toplevel;
      };
    };
}
