{config, lib, pkgs, ...}:
let
    useSecret = import ../../useSecret.nix;
    toRcloneINI = lib.generators.toINI {
        mkKeyValue = lib.generators.mkKeyValueDefault {
            # specifies the generated string for a subset of nix values
            mkValueString = lib.generators.mkValueStringDefault {};
        } "=";
    };
    rclonesync = pkgs.callPackage ../../packages/rclonesync {};
    syncDir = "${config.xdg.dataHome}/KeepassSync";
    workDir = "${syncDir}WD";
    filterFile = "${workDir}/filter.txt";
    rclonesyncCommand = ''${rclonesync}/bin/rclonesync nextcloud:Keepass "${syncDir}" --verbose --filters-file "${filterFile}" --workdir "${workDir}"'';
in
{

    home.packages = with pkgs; [
        keepassxc
        rclone
        rclonesync
    ];

    xdg.configFile."rclone/rclone.conf".text = (useSecret {
        callback = secrets: toRcloneINI secrets.rclone;
        default = "; No secrets could be loaded";
    });

    xdg.configFile."${filterFile}".text = ''
    + Passwords.kdbx
    + Passwords.keyx
    - *
    - **
    '';

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
            ExecStart = rclonesyncCommand;
            ExecStopPost = ''${pkgs.bash}/bin/bash -c 'if [ "$EXIT_STATUS" = 1 ]; then mkdir -p "${syncDir}"; elif [ "$EXIT_STATUS" = 2 ]; then ${rclonesyncCommand} --first-sync; fi' '';
        };
    };




}
