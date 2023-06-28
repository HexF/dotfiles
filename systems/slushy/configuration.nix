{ config, pkgs, ... }: {
  imports = [
    ../modules/base.nix
    ../modules/efi.nix
    ../modules/desktop.nix
    ../modules/wireless.nix
    ../modules/bluetooth.nix

    

    ./hardware-configuration.nix
  ];

  networking.hostName = "slushy";
  networking.hostId = "FFFFABCD";
}