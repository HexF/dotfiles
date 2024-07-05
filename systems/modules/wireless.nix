{ config, pkgs, ... }:
{
  networking.useNetworkd = true; # wifi roaming is shit without it
  
  networking.wireless = {
    enable = true;
    scanOnLowSignal = false;
    environmentFile = config.sops.secrets.wifi_env.path;
    networks = rec {
      "Moon" = {
        pskRaw = "@MOON_PSK@";
        priority = 10;
      };
      "Moon-5GHz" = {
        pskRaw = "@MOON_PSK@";
        priority = 20;
      };
      "OPPO Reno Z" = {
        pskRaw = "@PHONE_PSK@";
        priority = 0;
      };

      eduroam = {
        authProtocols = ["WPA-EAP"];
        auth = ''
          eap=PEAP
          identity="@UC_IDENTITY@"
          password="@UC_PASSWORD@"
          phase1="peaplabel=0"
          phase2="auth=MSCHAPV2"
        '';
      };

      "Unitedwifi.com" = {

      };

      "AirNZ In-Flight WiFi" = {
        pskRaw = "@HOME_PSK@";
        priority = 20;
      };

      # UCwireless = {
      #   authProtocols = ["WPA-EAP"];
      #   auth = ''
      #   eap=PEAP
      #   identity="@UC_IDENTITY@"
      #   password="@UC_PASSWORD@"
      #   phase1="peaplabel=0"
      #   phase2="auth=MSCHAPV2"
      #   '';
      # };
      #

      "TheDeltaQuadrant" = {
        psk = "@RHYS_PSK@";
        priority = 20;
      };


      
    };
  };

  sops.secrets.wifi_env = {
    key = "wifi_env";
    mode = "0400"; 
    sopsFile = ../secrets/secrets.yaml;

    restartUnits = [ "wpa_supplicant.service" ];
  };

  
}
