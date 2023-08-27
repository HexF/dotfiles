{ config, pkgs, ... }:

{
  services.fwupd.enable = true;

  boot = {
    lanzaboote = {
      enable = true;
      pkiBundle = "/persist/secureboot";
    };
    bootspec.enable = true;
    initrd.systemd.enable = true;
    plymouth = {
      enable = true;
    };
    efi.canTouchEfiVariables = true;
    loader = {
      systemd-boot = {
        enable = false;
        configurationLimit = 30;    
        editor = false;
        consoleMode = "max";
      };
      timeout = 0;
    };
  };
}