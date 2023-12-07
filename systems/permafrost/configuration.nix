{ config, pkgs, ... }: let
    tailnet = "fluffy-mercat.ts.net";
    akahu-firefly = (pkgs.callPackage ../../packages/akahu-firefly {});
in {

    imports = [
        ../modules/base.nix
        ../modules/efi.nix
        ../modules/server.nix

        ../modules/media-server.nix
        ../modules/tailscale-expose.nix

        ../modules/norgb.nix

        ./hardware-configuration.nix
    ];

    networking.hostName = "permafrost";
    networking.hostId = "DEAD0001";

    nixpkgs.config.packageOverrides = pkgs: {
        vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    };

    hardware.opengl = {
        enable = true;
        extraPackages = with pkgs; [
            intel-media-driver
            vaapiIntel
            vaapiVdpau
            libvdpau-va-gl
            intel-compute-runtime
        ];
    };

    sops.secrets = {
        nextcloud_restic_password = {
            key = "nextcloud_restic_password";
            mode = "0400";

            owner = "nextcloud";

            sopsFile = ./secrets/backup.yaml;
        };

        nextcloud_restic_env = {
            key = "nextcloud_restic_env";
            mode = "0400";

            owner = "nextcloud";

            sopsFile = ./secrets/backup.yaml;
        };

        firefly_restic_password = {
            key = "firefly_restic_password";
            mode = "0400";

            owner = config.services.firefly-iii.user;

            sopsFile = ./secrets/backup.yaml;
        };

        firefly_restic_env = {
            key = "firefly_restic_env";
            mode = "0400";

            owner = config.services.firefly-iii.user;

            sopsFile = ./secrets/backup.yaml;
        };
        
        firefly_appkey = {
            key = "app_key";
            mode = "0400";

            owner = config.services.firefly-iii.user;

            sopsFile = ./secrets/firefly.yaml;
        };

        "firefly_akahu_config.json" = {
            key = "akahu_link_config";
            mode = "0400";

            owner = config.services.firefly-iii.user;

            sopsFile = ./secrets/firefly.yaml;
        };
    };

    services.restic.backups = {
        nextcloud = {
            paths = [
                "/var/lib/nextcloud"
            ];

            initialize = true;

            passwordFile = config.sops.secrets.nextcloud_restic_password.path;
            environmentFile = config.sops.secrets.nextcloud_restic_env.path;

            repository = "b2:hexf-b2-backups:nextcloud";

            backupPrepareCommand = ''
                ${config.services.nextcloud.occ}/bin/nextcloud-occ maintenance:mode --on
                ${config.services.postgresql.package}/bin/pg_dump ${config.services.nextcloud.config.dbname} > /var/lib/nextcloud/nextcloud-dbdump.bak
            '';

            backupCleanupCommand = ''
                ${config.services.nextcloud.occ}/bin/nextcloud-occ maintenance:mode --off
            '';

            user = "nextcloud";

            timerConfig = {
                OnCalendar = "05:00"; # every day at 5am
                Persistent = true;
            };
        };

        firefly = {
            paths = [
                "/var/lib/firefly-iii"
            ];

            initialize = true;

            passwordFile = config.sops.secrets.firefly_restic_password.path;
            environmentFile = config.sops.secrets.firefly_restic_env.path;

            repository = "b2:hexf-b2-backups:firefly";

            backupPrepareCommand = ''
                ${config.services.mysql.package}/bin/mysqldump ${config.services.firefly-iii.database.name} > /var/lib/firefly-iii/firefly.sql
            '';

            user = config.services.firefly-iii.user;
            
            timerConfig = {
                OnCalendar = "05:00"; # every day at 5am
                Persistent = true;
            };
        };
    };

    services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud27;
        hostName = "localhost";
        https = true;
        config = {
            adminpassFile = "${pkgs.writeText "adminpass" "test123"}"; #immediately change this lol
            dbtype = "pgsql";
            extraTrustedDomains = [
                "nextcloud.${tailnet}"
            ];
        };

        extraApps = with config.services.nextcloud.package.packages.apps; {
            inherit news contacts calendar tasks;
        };
        extraAppsEnable = true;


        configureRedis = true;
        database.createLocally = true;
        notify_push.enable = true;
        # enableBrokenCiphersForSSE = false;
    };

    services.postgresql.package = pkgs.postgresql_16;
    # accept to nextcloud on 8001
    services.nginx.virtualHosts.${config.services.nextcloud.hostName}.listen = [{port = 8001; addr="127.0.0.1";}];

    # we need bleeding-edge tailscale for
    # https://github.com/tailscale/tailscale/commit/dc1d8826a2a16deda51ce20ef12bb31e1421bb97
    # so firefly wont commit CSP violation
    services.tailscale.package = pkgs.unstable.tailscale;

    services.firefly-iii = {
        enable = true;
        appURL = "https://firefly.${tailnet}";
        appKeyFile = config.sops.secrets.firefly_appkey.path;
        hostname = "firefly.${tailnet}";
        nginx = {
            listen = [{port = 8002; addr="127.0.0.1";}];
        };
        group = "nginx";
        database.createLocally = true;
        config = {
            USE_PROXIES = "127.0.0.1";
            TRUSTED_PROXIES = "**";
            TZ = "Pacific/Auckland";
        };
    };

    # akahu-firefly link
    systemd.services.akahu-firefly = {
      serviceConfig.Type = "oneshot";
      script = ''
        ${pkgs.nodejs}/bin/node ${akahu-firefly}/lib/node_modules/akahu-firefly ${config.sops.secrets."firefly_akahu_config.json".path}
      '';
    };

    systemd.timers.akahu-firefly = {
        wantedBy = ["timers.target"];
        partOf = ["akahu-firefly.service"];
        timerConfig = {
            OnCalendar = "*:*:0";
            Unit = "akahu-firefly.service";
        };
    };

    services.tailscale.expose = {
        enable = true;
        authKey = "file:/persist/tailscale-authkey"; #TODO - put in secrets
        dataDir = "/persist/tailscale-expose";
        services = {
            nextcloud = {
                httpsRoutes = {"/" = "http://localhost:8001";};
                funnel = true;
            };

            firefly = {
                httpsRoutes = {"/" = "http://localhost:8002";};
                funnel = false; # dont expose externally
            };

            jellyfin = {
                httpsRoutes = {"/" = "http://localhost:8096"; };
                funnel = true;
            };

            ombi = {
                httpsRoutes = {"/" = "http://localhost:${toString config.services.ombi.port}"; };
                funnel = true;
            };
        };
    };


    services.media-server = {
        enable = true;
        jellyfin.enable = true;
        sonarr.enable = true;
        radarr.enable = true;
        # jackett.enable = true;
        prowlarr.enable = true;
        ombi.enable = true;
        # lidarr.enable = true;
        # navidrome.enable = true;
        # unmanic.enable = true;

        vhostSuffix = ".pf.hexf.me";
    };    

    services.deluge = {
        enable = true;

        user = config.services.media-server.user;
        group = config.services.media-server.group;

        web = {
            enable = true;
            openFirewall = true;
        };
    };

    networking.firewall.allowedTCPPorts = [ 3000 80 ];

    # make it more desktopy
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    users.users.htpc = {
        isNormalUser  = true;
        description  = "HTPC user";
        extraGroups  = [ ];
    };

    services.xserver.displayManager.autoLogin.user = true;

    services.pipewire = {
        enable = true;

        alsa.enable = true;
        alsa.support32Bit = true;

        pulse.enable = true;
        jack.enable = true;

        # config.pipewire = {
        #   "context.properties" = {
        #     "log.level" = 3;
        #   };
        # };

    };
}