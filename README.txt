requires git-crypt when cloning


=== After partitioning and initial installation completed ===

# boot into system and login as root

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
nixos-rebuild --flake .#[system name] switch