# Installation

Firstly generate a gitcrypt.key from an existing system with

```sh
git-crypt export-key ./gitcrypt.key
```

Copy this file to the new system.

Boot into the new system and login as root

Run the following script

```sh
SYSTEMNAME=frostbite

cd /etc/nixos
nix-shell -p git git-crypt
git clone https://github.com/hexf/dotfiles
cd dotfiles

# Add to /etc/nixos/configuration.nix
# nix = {
#    package = pkgs.nixUnstable;
#    extraOptions = ''
#      experimental-features = nix-command flakes
#    '';
#   };

nixos-rebuild switch

# nixos-rebuild now supports flakes!

git-crypt unlock /path/to/gitcrypt.key

nixos-rebuild --flake ".#$SYSTEMNAME" switch
```
