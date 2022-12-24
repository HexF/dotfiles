{ config, pkgs, ... }:

{
  boot.blacklistedKernelModules = [
    "nfc"
    "pn533"
    "pn533_usb"
  ];


  environment.systemPackages = with pkgs; [
    libnfc
  ];

}
