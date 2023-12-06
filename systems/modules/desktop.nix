# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  services.xserver = {
    enable = true;
    displayManager = {
      lightdm = {
        enable = true;
        background = ../../wallpaper.jpg;
      };
    };
  };

  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  sound.enable = true;
  
  services.pipewire = {
    enable = true;

    alsa.enable = true;
    alsa.support32Bit = true;

    pulse.enable = true;
    jack.enable = true;

    # config.pipewire = {
    #   "context.properties" = {
    #     "log.level" = 3;
    #   };
    # };

  };
    

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;


  

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    firefox

    # gstreamer
    gst_all_1.gstreamer
    # Common plugins like "filesrc" to combine within e.g. gst-launch
    gst_all_1.gst-plugins-base
    # Specialized plugins separated by quality
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    # Plugins to reuse ffmpeg to play almost every video format
    gst_all_1.gst-libav
    # Support the Video Audio (Hardware) Acceleration API
    gst_all_1.gst-vaapi
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;


  programs.dconf.enable = true;
  # EasyEffects and other dconf dependencies

  services.printing = {
    enable = true;
  };

  services.avahi = {
    enable = true;
    nssmdns = true;
  };

}

