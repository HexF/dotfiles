{ config, pkgs, ... }:

{

  sops = {
    defaultSopsFile = "../${config.networking.hostName}/secrets/secrets.yaml";
    
    age = {
      keyFile = "/persist/sops-nix/key.txt";
      generateKey = true; # Generate if it doesn't exist
    };
  };

  nix = { 
    package = pkgs.nixFlakes;
    settings = {
      trusted-public-keys = [
        "binarycache.hexf.me:q/9RfEEQCO+/cbCNZ47hcAwoHyZ14v0N6FFwN5UZFzk="
      ];
      substituters = [
  #      "https://binarycache.hexf.me/"
      ];
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  time.timeZone = "Pacific/Auckland";
  
  networking.useDHCP = true;
  networking.dhcpcd.wait = "background";
  
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1v"
  ];
  nixpkgs.config.allowBroken = true;
  nixpkgs.config.segger-jlink.acceptLicense = true;
  nixpkgs.config.nvidia.acceptLicense = true;

  # TAILSCALE EVERYWHERE!
  services.tailscale.enable = true;
  networking.firewall.checkReversePath = "loose";
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # Fixes tailscale stealing DNS
  services.resolved.enable = true;

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

  security.polkit.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
