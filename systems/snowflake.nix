# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  mkBackup = import ./common/backup.nix;
in {
  imports = [
    ./common/base.nix
    ./common/efi.nix
    ./common/desktop.nix
    ./common/bluetooth.nix
    ./snowflake-hardware.nix
  ];

  services.udev.packages = [ pkgs.stlink pkgs.openocd ];

  services.ratbagd.enable = true; # Compliments Piper


  networking.interfaces.enp3s0.useDHCP = true;
  networking.hostName = "snowflake";
  networking.hostId = "fdab470e";
  
  boot.kernelParams = [ "intel_pstate=active" "nvidia-drm.modeset=1" ];
  boot.initrd.compressor = "cat";
  boot.initrd.kernelModules = config.boot.kernelModules;
  

  services.xserver = {
    videoDrivers = [ "nvidia" ];
    wacom.enable = true;

    xrandrHeads = [
      "HDMI-0"
      { output = "DP-0"; primary = true; }
      { monitorConfig = ''Option "Rotate" "inverted"''; output = "DVI-D-0"; }
    ];
  };

  services.borgbackup.jobs = {
    snowflake-home-thobson = mkBackup "snowflake-home-thobson" "/home/thobson" [
      "/home/thobson/.cache"
      "/home/thobson/.config"
      "/home/thobson/Downloads"
      "/nix"
    ];
  };


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups.plugdev = {};
  users.users.thobson.extraGroups = [ "docker" "plugdev" "dialout" ]; 

  programs.steam.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    texlive.combined.scheme-full
    docker-compose
    piper
  ];

  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "hourly";
    };
    enableOnBoot = false;
  };

  networking.firewall.allowedTCPPorts = [ 3000 3001 2759 ]; # React dev server

  fonts.fonts = with pkgs; [
    fira
  ];
}

