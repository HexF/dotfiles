{ config, pkgs, ... }:

{
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  hardware.pulseaudio = {
      # Provides AAC, APTX, etc.
      extraModules = [ pkgs.pulseaudio-modules-bt ];
      package = pkgs.pulseaudioFull; 
  };
}