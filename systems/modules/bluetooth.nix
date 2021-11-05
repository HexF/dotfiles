{ config, pkgs, ... }:

{
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  hardware.pulseaudio = {
      # Provides AAC, APTX, etc.
      extraModules = [ pkgs.pulseaudio-modules-bt ];
      package = pkgs.pulseaudioFull; 
  };

  # Pin this specific kernel version because it includes support for mSBC via alt1
  # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/1366
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_5_13.override {
    argsOverride = rec {
      src = pkgs.fetchurl {
            url = "mirror://kernel/linux/kernel/v5.x/linux-${version}.tar.xz";
            sha256 = "sha256-w5QNCc+2KfjBQLewmM9jVtYM2AQ99rF8HwBAdyacqTc=";
      };
      version = "5.13.2";
      modDirVersion = "5.13.2";
      };
  });

  services.pipewire  = {
    media-session.config.bluez-monitor.properties = {
        # Forces these on
        "bluez5.enable-msbc" = "true";
        "bluez5.enable-sbc-xq" = "true";
    };
    media-session.config.bluez-monitor.rules = [
        {
        # Matches all cards
        matches = [ { "device.name" = "~bluez_card.*"; } ];
        actions = {
            "update-props" = {
                "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
                # mSBC is not expected to work on all headset + adapter combinations.
                "bluez5.msbc-support" = true;
                # SBC-XQ is not expected to work on all headset + adapter combinations.
                "bluez5.sbc-xq-support" = true;

            };
        };
        }
        {
        matches = [
            # Matches all sources
            { "node.name" = "~bluez_input.*"; }
            # Matches all outputs
            { "node.name" = "~bluez_output.*"; }
        ];
        actions = {
            "node.pause-on-idle" = false;
        };
        }
    ];
    };

}