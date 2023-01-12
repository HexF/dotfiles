{config, lib, pkgs, ...}:
{

    home.packages = with pkgs; [
        rclone
        (keepassxc.overrideAttrs(old: {
            version = "remotesync";

            src = fetchFromGitHub {
                owner = "t-h-e";
                repo = "keepassxc";
                rev = "f53ba47a66ca7d78264c0a2e29c6d7bdaa9ef0e6";
                sha256 = "sha256-SptS8AIOPe7/3XMnzsdzgF/HdfPF6ViZOrtte4i9YTA=";
            };
        })) # Remote sync to upload/download files to nextcloud
    ];

    # Download
    # rclone --config /run/secrets/thobson_rclone_config copy nextcloud:Passwords.kdbx {TEMP_DATABASE}

    # Upload
    # rclone --config /run/secrets/thobson_rclone_config copy {TEMP_DATABASE} nextcloud:Passwords.kdbx

}
