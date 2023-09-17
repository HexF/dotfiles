{
  description = "HexF's dotfiles";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-23.05";
    nixpkgs.url = "github:HexF/nixpkgs?ref=nixos-23.05";
    #nixpkgs.url = "git+file:/home/thobson/Projects.local/nixpkgs";
    nixpkgs-master.url = "github:NixOS/nixpkgs?ref=master";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

    firefly.url = "github:timhae/firefly";
    firefly.inputs.nixpkgs.follows = "nixpkgs";

    devenv.url = "github:cachix/devenv/latest";

    napalm.url = "github:nix-community/napalm";
    napalm.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = "github:nix-community/lanzaboote";

    home-manager = {
      url = "github:nix-community/home-manager?ref=release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { ... } @ args: import ./outputs.nix args;
}
