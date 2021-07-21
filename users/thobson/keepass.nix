{config, lib, pkgs, ...}:
let
    useSecret = import ../../useSecret.nix;
    toRcloneINI = lib.generators.toINI {
        mkKeyValue = lib.generators.mkKeyValueDefault {
            # specifies the generated string for a subset of nix values
            mkValueString = lib.generators.mkValueStringDefault {};
        } "=";
    };
in
{

    home.packages = with pkgs; [
    keepassxc
    rclone
    ];

    xdg.configFile."rclone/rclone.conf".text = (useSecret {
        callback = secrets: toRcloneINI secrets.rclone;
    });

    systemd.user.timers.keepass-sync = {
        Unit = {
            Description = "Sync Keepass database every 5 minutes";
        };
        Timer = {
            OnCalendar="*-*-* *:0/5:00";
        };
        Install = {
            WantedBy = ["timers.target"];
        };

    };

    systemd.user.services.keepass-sync = {
        Unit = {
            Description = "Sync Keepass database from Nextcloud";
        };
        Service = {
            ExecStart = "${pkgs.rclone}/bin/rclone sync nextcloud:Passwords.kdbx ~/.local/share/KeepassSync";
        };
    };




}
