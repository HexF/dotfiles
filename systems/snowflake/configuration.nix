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
    ../modules/thobson-nextcloud.nix
    ../modules/acr122.nix
    ../modules/waydroid.nix

    # ../modules/htb-vpn.nix

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
  # boot.kernelPatches = lib.singleton {
  #   name = "disable compression";
  #   patch = null;
  #   extraConfig = ''
  #     KERNEL_XZ n
  #     KERNEL_ZSTD n
  #     MODULE_COMPRESS_XZ n
  #     MODULE_COMPRESS_NONE y
  #   '';
  # };

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

  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
    i3lock-color.u2fAuth = true;
    i3lock.u2fAuth = true;
    swaylock = {};
  };
  

  services.xserver = {
    videoDrivers = [ "nvidia" ];
    wacom.enable = true;

    xrandrHeads = [
      "HDMI-0"
      "DP-0"
      "DVI-I-1"
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
  users.users.thobson.extraGroups = [ "docker" "plugdev" "dialout" "adbusers" ]; 

  programs.adb.enable = true;

  programs.steam.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    texlive.combined.scheme-full
    docker-compose
    piper
    glibc
    bpftrace
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



  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true; # for solaar to be included



  # networking.wireguard.interfaces = {
  #   wg0 = {
  #     ips = [ "172.17.1.26/32" ];
  #     privateKey = "IDQVPrUYJex24WaTWvn8QOEcwXFzsb2id+B3BX3p224=";

  #     peers = [
  #       {
  #         publicKey = "IwEogecDJ2dJwkVDGQXw6di3/4YmcJ4YRcnNGT5aYAU=";
  #         allowedIPs = [ "172.16.0.0/15" ];
  #         endpoint = "oiccquals2.cyber.uq.edu.au:51820";
  #       }
  #     ];
  #   };
  # };

}

