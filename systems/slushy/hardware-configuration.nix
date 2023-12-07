# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.supportedFilesystems = [ "zfs" ];

  boot.kernelPackages = pkgs.linuxPackages_6_1;

  # Fix ZFS scheduling
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
  '';
  
  boot.kernelParams = [
    "nohibernate" # ZFS doesn't support hibernation - can lead to FS corruption
    "quiet" # plymouth
  ];
  # https://github.com/openzfs/zfs/issues/260

  fileSystems."/" = {
    device = "rpool/root/nixos";
    fsType = "zfs";
  };

  # boot.initrd.clevis.enable = true;

  fileSystems."/home" = {
    device = "rpool/home-enc";
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


  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/C17A-510E";
    fsType = "vfat";
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = true;
}


