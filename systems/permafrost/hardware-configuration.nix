# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.supportedFilesystems = [ "zfs" ];

  boot.kernelPackages = pkgs.linuxPackages_6_6;

  # Fix ZFS scheduling
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
  '';
  
  boot.kernelParams = [
    "nohibernate" # ZFS doesn't support hibernation - can lead to FS corruption
  ];
  # https://github.com/openzfs/zfs/issues/260

  fileSystems."/" = {
    device = "rpool/root/nixos";
    fsType = "zfs";
  };

  # boot.initrd.clevis.enable = true;

  fileSystems."/home" = {
    device = "rpool/home";
    fsType = "zfs";
  };

  fileSystems."/nix" = {
    device = "rpool/nix";
    fsType = "zfs";
  };

  fileSystems."/persist" = {
    device = "rpool/persist";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/var/lib/nextcloud" = {
    device = "spool/nextcloud";
    fsType = "zfs";
  };

  fileSystems."/var/lib/seafile" = {
    device = "spool/seafile";
    fsType = "zfs";
  };

  fileSystems."/var/lib/postgresql" = {
    device = "spool/postgres";
    fsType = "zfs";
  };

  fileSystems."/var/lib/media" = {
    device = "spool/media";
    fsType = "zfs";
  };


  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/F43C-5B13";
    fsType = "vfat";
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = true;
}


