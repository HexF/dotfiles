{
  description = "HexF's dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, home-manager, nixpkgs }: {

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



  };
}
