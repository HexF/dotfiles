{ config, pkgs, ... }: {
  imports = [
    ../modules/base.nix
    ../modules/efi.nix
    ../modules/desktop.nix
    ../modules/wireless.nix
    ../modules/bluetooth.nix

    

    ./hardware-configuration.nix
  ];

    
  networking.interfaces.ens192.useDHCP = true;
  networking.hostName = "hydroxide";

  networking.firewall.allowedTCPPorts = [ 3000 80 ];
}