{config, lib, pkgs, modulesPath, ...}:

{
    imports = [];

    boot.initrd.availableKernelModules = [ "ata_piix" "ahci" "vmw_pvscsi" "sd_mod" "sr_mod" ];
    boot.initrd.kernelModules = [];
    boot.kernelModules = [];
    boot.extraModulePackages = [];


    fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
    };

    boot.loader.grub.devices = [ "/dev/sda" ];

    swapDevices = [
        {
            device = "/dev/disk/by-label/swap";
        }
    ];


}