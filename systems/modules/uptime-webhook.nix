{ config, pkgs, ... }:

{
  sops.secrets = {
      snowflake_uptime_webhook = {
          key = "uptime_webhook";
          mode = "0400"; #TODO: fix permissions - doesnt need to be world readable

          sopsFile = ../snowflake/secrets/secrets.yaml;
      };
  };

  systemd.services.post-uptime-webhook = {
      serviceConfig.Type = "oneshot";
      path = with pkgs; [bash curl gawk];
      script = ''
        awk '{print "{\"content\":\"HexF Uptime: "int($1/86400)" days, "int(($1%86400)/3600)" hours, "int(($1%3600)/60)" minutes, "int($1%60)" seconds\"}"}' /proc/uptime | curl -XPOST -H "Content-Type: application/json" --data @- $(cat ${config.sops.secrets.snowflake_uptime_webhook.path})
      '';
  };

  systemd.timers.post-uptime-webhook = {
      wantedBy = ["timers.target"];
      partOf = ["post-uptime-webhook.service"];
      timerConfig = {
          OnCalendar = "*:*:0";
          Unit = "post-uptime-webhook.service";
      };
    
  };

}