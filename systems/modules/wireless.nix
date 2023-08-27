{ config, pkgs, ... }:
{
  
  networking.wireless = {
    enable = true;
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


      
    };
  };

  sops.secrets.wifi_env = {
    key = "wifi_env";
    mode = "0400"; 
    sopsFile = ../secrets/secrets.yaml;

    restartUnits = [ "wpa_supplicant.service" ];
  };

  
}