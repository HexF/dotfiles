{
    nixpkgs,
    nixosSystem,
    sops-nix,
    nixpkgs-master,
    nixpkgs-unstable,
    nixpkgs-nextcloud,
    home-manager,
    napalm,
    lanzaboote,
    devenv,
    nix-minecraft
} @ inputs:

let
    defaultModules = [
        lanzaboote.nixosModules.lanzaboote
        sops-nix.nixosModules.sops
        {
            nixpkgs.overlays = [
                (final: prev: {
                    master = (import nixpkgs-master {
                        config.allowUnfree = true;
                        system = "${prev.system}";
                    });
                })
                (final: prev: {
                    nextcloudpkgs = (import nixpkgs-nextcloud {
                        config.allowUnfree = true;
                        system = "${prev.system}";
                    });
                })
                (final: prev: {
                    unstable = (import nixpkgs-unstable {
                        config.allowUnfree = true;
                        config.nvidia.acceptLicense = true;
                        system = "${prev.system}";
                    });
                })
                (final: prev: {
                    devenv = devenv.packages."${prev.system}".devenv;
                })
                napalm.overlays.default
                nix-minecraft.overlay
            ];
        }
        nix-minecraft.nixosModules.minecraft-servers
    ];
    
    userModules = (systemName: [
            home-manager.nixosModules.home-manager
            {
                home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    extraSpecialArgs = {
                        inherit systemName nixpkgs;
                    };

                    users.thobson = ../users/thobson/home.nix;
                };
            }
        ]
    );
in {
    snowflake = nixosSystem {
        system = "x86_64-linux";
        modules = defaultModules ++ [
            ./snowflake/configuration.nix
            ./modules/thobson-secrets.nix
        ] ++ (userModules "snowflake");
    };

    slushy = nixosSystem {
        system = "x86_64-linux";
        modules = defaultModules ++ [
            ./slushy/configuration.nix
            ./modules/thobson-secrets.nix
        ] ++ (userModules "slushy");
    };

    permafrost = nixosSystem {
        system = "x86_64-linux";
        modules = defaultModules ++ [
            ./permafrost/configuration.nix
        ] ++ (userModules "permafrost");
    };

    hydroxide = nixosSystem {
        system = "x86_64-linux";
        modules = defaultModules ++ [
            ./hydroxide/configuration.nix
        ];
    };

    frostbite = nixosSystem {
        system = "x86_64-linux";
        modules = defaultModules ++ [
            ./frostbite/configuration.nix
        ] ++ (userModules "frostbite");
    };
}