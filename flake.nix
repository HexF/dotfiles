{
  description = "HexF's dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    nixpkgs-nix.url = "github:NixOS/nixpkgs/4586b2f0d0cce2916766dfcd1b717c0940d865ef";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, home-manager, nixpkgs, nixpkgs-nix }: {
    
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

      hydroxide = nixpkgs-nix.lib.nixosSystem {
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
