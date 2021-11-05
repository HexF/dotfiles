{config}: name: paths: exclude: {
    inherit paths exclude;
    encryption.mode = "repokey";
    encryption.passCommand = "cat ${config.sops.secrets.backup_passphrase.path}";
    environment.BORG_RSH = "ssh -o 'StrictHostKeyChecking=no' -i ${config.sops.secrets.backup_ssh_key.path}";
    repo = "ssh://thomas@192.168.1.101//volume4/Thomas-PC-Backup/Backups/${name}";
    compression = "auto,lzma";
    extraCreateArgs = "--verbose --stats --checkpoint-interval 600";
    startAt = "hourly";
    extraArgs = "--remote-path=/usr/local/bin/borg";
}