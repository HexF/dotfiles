{ config, pkgs, ... }:

{
  sops.secrets = {
      thobson_ssh_hosts = {
          key = "ssh_hosts";
          mode = "0400";

          owner = config.users.users.thobson.name;

          sopsFile = ../secrets/thobson.yaml;
      };

      thobson_mopidy_config = {
          key = "mopidy_config";
          mode = "0400";

          owner = config.users.users.thobson.name;

          sopsFile = ../secrets/thobson.yaml;
      };

      thobson_rclone_config = {
          key = "rclone_config";
          mode = "0400";

          owner = config.users.users.thobson.name;

          sopsFile = ../secrets/thobson.yaml;
      };

      thobson_keepass_password = {
          key = "keepass_password";
          mode = "0400";

          owner = config.users.users.thobson.name;

          sopsFile = ../secrets/thobson.yaml;
      };
  };
}