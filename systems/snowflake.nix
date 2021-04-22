# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{


  services.udev.packages = [ pkgs.stlink pkgs.openocd ];


  networking.interfaces.enp3s0.useDHCP = true;
  networking.hostName = "snowflake";

  boot.kernelParams = [ "intel_pstate=active" ];
  #boot.kernelPackages = pkgs.linuxPackages_5_4;
  # 285301cd1f3ec4521be8a9b816a99a095c34715c in nixpkgs seems to hurt performance, wait until patch


  services.xserver = {
    videoDrivers = [ "nvidia" ];

    xrandrHeads = [
      "HDMI-0"
      { output = "DP-0"; primary = true; }
      { monitorConfig = ''Option "Rotate" "inverted"''; output = "DVI-D-0"; }
    ];
  };


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups.plugdev = {};
  users.users.thobson.extraGroups = [ "docker" "plugdev" "dialout" ]; 
  

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    texlive.combined.scheme-full
    docker-compose
  ];

  virtualisation.docker.enable = true;

  networking.firewall.allowedTCPPorts = [ 3000 ]; # React dev server
}

