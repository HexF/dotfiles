{
    nixpkgs,
    nixosSystem,
    sops-nix,
    nixpkgs-master,
    nixpkgs-unstable,
    home-manager
} @ inputs: {
    thobson =  home-manager.lib.homeManagerConfiguration {
        system = nixosSystem;
        homeDirectory = "/home/thobson";
        username = "thobson";
        configuration.imports = [
            ./users/thobson/home.nix
        ];
    };
}