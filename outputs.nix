{
    self,

    nixpkgs,
    nixpkgs-master,
    nixpkgs-unstable,
    nixpkgs-nextcloud,

    home-manager,
    sops-nix,
    flake-utils,

    napalm,
    lanzaboote,
    devenv,

    nix-minecraft

   
}: (
    flake-utils.lib.eachDefaultSystem (system: 
        let
            pkgs = nixpkgs.legacyPackages.${system};
        in {
            

            devShell = pkgs.mkShell {
                sopsPGPKeyDirs = [ 
                    "./systems/secrets/keys/hosts"
                    "./systems/secrets/keys/users"
                ];

                nativeBuildInputs = [
                    (pkgs.callPackage sops-nix {}).sops-import-keys-hook
                ];
            };
        }    
    )
) // {
    nixosConfigurations = import ./systems/configurations.nix {
        nixosSystem = nixpkgs.lib.nixosSystem;
        inherit
            nixpkgs
            nixpkgs-master
            nixpkgs-unstable
            nixpkgs-nextcloud
            home-manager
            sops-nix
            napalm
            devenv
            lanzaboote
            nix-minecraft
            ;
    };

    homeConfigurations = import ./users/configurations.nix {
        nixosSystem = nixpkgs.lib.nixosSystem;
        inherit
            nixpkgs
            nixpkgs-master
            nixpkgs-unstable
            home-manager
            sops-nix
            napalm
            ;
    };

    hydraJobs = {
        hydroxide = self.nixosConfigurations.hydroxide.config.system.build.toplevel;
        snowflake = self.nixosConfigurations.snowflake.config.system.build.toplevel;
        frostbite = self.nixosConfigurations.frostbite.config.system.build.toplevel;
    };
}