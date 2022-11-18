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
    ../modules/uptime-webhook.nix

    ../modules/dm-xsession.nix
    #../modules/dm-kde.nix

    ./modules/windows-vm.nix

    ./hardware-configuration.nix
  ];

  #boot.kernelPackages = pkgs.linuxPackages_latest;
  
  # FIXME: Kernel 6.0 does not support Nvidia Drivers - https://github.com/NixOS/nixpkgs/issues/195654
  boot.kernelPackages = pkgs.linuxPackages_5_15;

  boot.blacklistedKernelModules = [
    "nvidia_uvm"
  ];

  # Don't compress kernel and modules
  boot.kernelPatches = lib.singleton {
    name = "disable compression";
    patch = null;
    extraConfig = ''
      KERNEL_XZ n
      KERNEL_ZSTD n
      MODULE_COMPRESS_XZ n
      MODULE_COMPRESS_NONE y
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
    videoDrivers = [ "nvidia" ];
    wacom.enable = true;

    xrandrHeads = [
      { output = "DP-0"; primary = true; }
      "HDMI-0"
      { monitorConfig = ''Option "Rotate" "inverted"''; output = "DVI-D-0"; }
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
    glibc
  ];

  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "hourly";
    };
    enableOnBoot = false;
  };

  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
  
  networking.firewall.allowedTCPPorts = [ 3000 3001 2759 443 80 ]; # React dev server

  fonts.fonts = with pkgs; [
    fira
  ];
}

