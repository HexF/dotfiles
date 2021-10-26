let
  useSecret = import ../../useSecret.nix;
in name: paths: exclude: useSecret {
    callback = secrets: {
        inherit paths exclude;
        encryption.mode = "repokey";
        encryption.passphrase = secrets.backups.passphrase;
        environment.BORG_RSH = "ssh -o 'StrictHostKeyChecking=no' -i ${secrets.backups.sshKeyPath}";
        repo = "${secrets.backups.location}/${name}";
        compression = "auto,lzma";
        extraCreateArgs = "--verbose --stats --checkpoint-interval 600";
        startAt = "hourly";
        extraArgs = "--remote-path=/usr/local/bin/borg";
    };
    default = {};
}