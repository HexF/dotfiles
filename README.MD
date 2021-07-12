# Installation

Firstly generate a gitcrypt.key from an existing system with

```sh
git-crypt export-key ./gitcrypt.key
```

Copy this file to the new system.

Next take a copy of GPG keys and SSH keys with:

```sh
gpg --list-secret-keys --keyid-format LONG
# find key ID, usually the long part

gpg --armor --export-secret-keys [keyid] > gpg.key
```

# Export SSH

cp ~/.ssh/id_ed25519 keys/id_ed25519

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

Now reboot, switch tty, login with root, `passwd thobson`, setting a password, then login on tty7.

Launch a terminal and run

```sh
# Install Keys
gpg --import gpg.key
cp id_ed25519 ~/.ssh/
chmod 0600 ~/.ssh/id_ed25519

# Clone dotfiles into ~/
cd ~
git clone git@github.com:HexF/dotfiles.git
```
