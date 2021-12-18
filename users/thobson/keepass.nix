{config, lib, pkgs, ...}:
let
    rcloneConfPath = "/run/secrets/thobson_rclone_config";
    keepassSecretPath = "/run/secrets/thobson_keepass_password";
    syncDir = "${config.xdg.dataHome}/KeepassSync";
    cloneAndMergeDatabases = pkgs.writeShellScriptBin "cloneAndMergeDatabases" ''
        export TMPDIR=$HOME/tmp
        ${pkgs.coreutils}/bin/mkdir -p $TMPDIR
        tempdir=$(${pkgs.mktemp}/bin/mktemp -d -t passwordsync-XXXXXXXXXX.tmp)

        function cleanup {
            ${pkgs.coreutils}/bin/rm -rf "$tempdir"
        }
        trap cleanup EXIT

        echo Temp dir: $tempdir
        echo TMPDIR: $TMPDIR
        echo HOME: $HOME

        ${pkgs.rclone}/bin/rclone copy --config "${rcloneConfPath}" --progress nextcloud:Keepass "$tempdir" 

        ${pkgs.keepassxc}/bin/keepassxc-cli merge -s -k "${syncDir}/Passwords.keyx" "${syncDir}/Passwords.kdbx" "$tempdir/Passwords.kdbx" <"${keepassSecretPath}"

        ${pkgs.rclone}/bin/rclone copy --config "${rcloneConfPath}" --progress "${syncDir}/Passwords.kdbx" nextcloud:Keepass/
    '';
    unlockDatabaseScript = pkgs.writeShellScriptBin "keepass-unlock" ''

        if ! pgrep keepassxc-wrap > /dev/null
        then
            keepassxc &
        fi
        
        tmp_passwd=$(cat ${keepassSecretPath})
        dbus-send --print-reply --dest=org.keepassxc.KeePassXC.MainWindow /keepassxc org.keepassxc.MainWindow.openDatabase \
            string:${syncDir}/Passwords.kdbx string:$tmp_passwd string:${syncDir}/Passwords.keyx

    '';

in
{

    home.packages = with pkgs; [
        keepassxc
    ];

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
            ExecStart = "${cloneAndMergeDatabases}/bin/cloneAndMergeDatabases";
        };
    };




}
