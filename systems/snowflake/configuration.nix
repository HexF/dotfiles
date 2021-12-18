# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:
let
  mkBackup = import ../helpers/backup.nix {inherit config;};
in {
  imports = [
    ../modules/base.nix
    ../modules/efi.nix
    ../modules/desktop.nix
    ../modules/bluetooth.nix
    ../modules/backup.nix

    ../modules/dm-xsession.nix
    #../modules/dm-kde.nix

    ./modules/windows-vm.nix

    ./hardware-configuration.nix
  ];

  # Don't compress kernel and modules
  boot.kernelPatches = lib.singleton {
    name = "disable compression";
    patch = null;
    extraConfig = ''
      KERNEL_XZ n
      KERNEL_ZSTD n
      MODULE_COMPRESS n
      MODULE_COMPRESS_XZ n
    '';
  };

  services.udev.packages = [ pkgs.stlink pkgs.openocd ];

  services.ratbagd.enable = true; # Compliments Piper



  networking.interfaces.enp3s0.useDHCP = true;
  networking.hostName = "snowflake";
  networking.hostId = "fdab470e";
  
  boot.kernelParams = [
    "intel_pstate=active"
  ];
  
  boot.initrd.compressor = "cat";
  boot.initrd.kernelModules = config.boot.kernelModules;
  

  services.xserver = {
    videoDrivers = [ "nouveau" ];
    wacom.enable = true;

    xrandrHeads = [
      { output = "DP-1"; primary = true; }
      "HDMI-1"
      { monitorConfig = ''Option "Rotate" "inverted"''; output = "DVI-D-1"; }
    ];
  };

  services.logind.extraConfig = ''
    # don’t shutdown when power button is short-pressed
    HandlePowerKey=suspend-then-hibernate
  '';

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
  '';


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

