{config, lib, pkgs, ...}:
{

    home.packages = with pkgs; [
        rclone
        # (keepassxc.overrideAttrs(old: {
        #     version = "2.8.0-snapshot";

        #     src = fetchFromGitHub {
        #         owner = "keepassxreboot";
        #         rev = "6f2354c0e94e79b0a87d9f116957df5a509149ed";
        #         # owner = "t-h-e";
        #         # rev = "7b368dc335f8ecd0fe26577d80cbea7ca07a1750";
        #         # sha256 = "sha256-cmiHst3q7khlB1+Au0inH4VjbDCIO1APy8rUxuDezXU=";

        #         # owner = "hexf";
        #         # rev= "0f60506352d1b38d5ab45eb8218c66c68fe79ea5";
        #         # sha256 = "sha256-4BBjVsaF3l6ZtEpgIMkmjw8nCWlXfUwH4nGhJvfdVbA=";

        #         repo = "keepassxc";
                
        #     };

        #     buildInputs = old.buildInputs ++ [keyutils];
        # })) # Remote sync to upload/download files to nextcloud
    ];

    # Download
    # rclone --config /run/secrets/thobson_rclone_config copy nextcloud:Passwords.kdbx {TEMP_DATABASE}

    # Upload
    # rclone --config /run/secrets/thobson_rclone_config copy {TEMP_DATABASE} nextcloud:Passwords.kdbx

}
