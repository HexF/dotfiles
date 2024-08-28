# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:
let
  mkBackup = import ../helpers/backup.nix {inherit config;};
in {
  imports = [
    ../modules/base.nix
    # ../modules/efi.nix
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

  boot = {
    lanzaboote = {
      enable = false;
      pkiBundle = "/persist/secureboot";
    };
    bootspec.enable = true;
    initrd.systemd.enable = true;
    plymouth = {
      enable = true;
    };
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 2;    
        editor = false;
        consoleMode = "max";
      };
      timeout = 0;
    };
  };
  
  # FIXME: Kernel 6.0 does not support Nvidia Drivers - https://github.com/NixOS/nixpkgs/issues/195654
  # boot.kernelPackages = pkgs.unstable.linuxPackages_5_15;

  # boot.kernelPatches = [{
  #   name = "random usb webcam";
  #   patch = ./quirk_usbwebcam.patch;
  # }];

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
    "i915.enable_ips=0"
  ];

  boot.extraModprobeConfig = ''
    options nvidia NVreg_RegistryDwords=RMUseSwI2c=0x01;RMI2cSpeed=100
  '';
  
  # boot.initrd.compressor = "cat";
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
    # drivers = lib.mkForce [
    #   {
    #     name = "nvidia-r1";
    #     modules = [
    #       config.hardware.nvidia.package.bin
    #     ];
    #     driverName = "nvidia";
    #     display = true;
    #     deviceSection = ''
    #       VendorName     "NVIDIA Corporation"
    #       BoardName      "NVIDIA GeForce GTX 750 Ti"
    #       BusID          "PCI:1:0:0"
    #     '';

    #     screenSection = ''
    #       Monitor "Monitor-R1"
    #       Option "metamodes" "GPU-0.HDMI-0: nvidia-auto-select +0+0, GPU-0.DVI-I-1: nvidia-auto-select +1920+0, GPU-1.HDMI-0: nvidia-auto-select +1920+1080"
    #       Option "SLI" "Off"
    #       Option "MultiGPU" "Off"
    #       Option "BaseMosaic" "Off"
    #     '';

    #   }

    #   {
    #     name = "nvidia-r2";
    #     modules = [
    #       config.hardware.nvidia.package.bin
    #     ];
    #     driverName = "nvidia";
    #     display = true;
        
    #     deviceSection = ''
    #       VendorName     "NVIDIA Corporation"
    #       BoardName      "NVIDIA GeForce GTX 760"
    #       BusID          "PCI:6:0:0"
    #     '';

    #     screenSection = ''
    #       Monitor "Monitor-R2"
    #       Option "metamodes" "nvidia-auto-select +1920+1080 {AllowGSYNC=Off}"
    #       Option "SLI" "Off"
    #       Option "MultiGPU" "Off"
    #       Option "BaseMosaic" "off"
    #     '';
    #   }
    # ];

    wacom.enable = true;

    xrandrHeads = [
      {
        output = "DVI-D-0";
        primary = true;
      }
      {
        output = "DP-0";
        monitorConfig = ''
          Option "RightOf" "DVI-D-0"
        '';
      }
      {
        output = "HDMI-0";
        monitorConfig = ''
          Option "RightOf" "DP-0"
        '';
      }
      {
        output = "DVI-I-1";
        monitorConfig = ''
          Option "RightOf" "HDMI-0"
        '';
      }     
    ];

    serverLayoutSection = ''
    Option "Xinerama" "0"
    '';


  };

  # services.pcscd.enable = true;

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
#     (segger-jlink.overrideAttrs (finalAttrs: previousAttrs: rec {
#       version = "788m";
#       src = fetchurl {
#         url = "https://www.segger.com/downloads/jlink/JLink_Linux_V${version}_x86_64.tgz";
#         sha256 = "sha256-WwUF/DZ+vECG30quvotMQFverTtj+pfQh2sEZl2mkPQ=";
#         curlOpts = "--data accept_license_agreement=accepted";
#       };
#       postInstall = ''
# #        mkdir -p $out/bin/ETC/JFlash
#         cp ETC -r $out/bin/
#       '';
#     }))
  _1password-gui

  (stdenv.mkDerivation rec {
    name = "onepassword-polkit";

    src = ./onepwpolicy.xml;

    unpackPhase = "true";

    installPhase = ''
      mkdir -p $out/share/polkit-1/actions/
      cp $src $out/share/polkit-1/actions/com.1password.1Password.policy
    '';
  })
    
  ];

  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "hourly";
    };
    enableOnBoot = false;
    extraOptions = "--insecure-registry 100.108.118.134:5000";
  };

  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
  hardware.nvidia.modesetting.enable = true;
  
  networking.firewall.allowedTCPPorts = [ 3000 3001 2759 443 80 ]; # React dev server

  fonts.packages = with pkgs; [
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

