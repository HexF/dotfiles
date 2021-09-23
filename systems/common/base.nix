{ config, pkgs, ... }:

{
  
  nix = { 
    package = pkgs.nixFlakes;
    binaryCachePublicKeys = [
      "binarycache.hexf.me:q/9RfEEQCO+/cbCNZ47hcAwoHyZ14v0N6FFwN5UZFzk="
    ];
    binaryCaches = [
#      "https://binarycache.hexf.me/"
    ];
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  time.timeZone = "Pacific/Auckland";
  
  networking.useDHCP = false;
  networking.dhcpcd.wait = "background";
  
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = true;
  users.users.thobson = {
    isNormalUser = true;
    extraGroups = [ "sudoers" "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    neovim
    git
    git-crypt
  ];

  programs.zsh.enable = true;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}