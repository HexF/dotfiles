{ config, pkgs, ... }:
{
    sops.secrets = {
        backup_ssh_key = {
            key = "ssh_key";
            mode = "0400";

            sopsFile = ../secrets/backup.yaml;
        };

        backup_passphrase = {
            key = "passphrase";
            mode = "0400";

            sopsFile = ../secrets/backup.yaml;
        };
    };
}
