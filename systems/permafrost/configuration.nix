{ config, pkgs, lib, ... }: let
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

    boot.loader.systemd-boot.memtest86.enable = true; # memtest86!

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

        firefox-sync-environment-file = {
            key = "environment_file";
            mode = "0400";

            owner = "root";

            sopsFile = ./secrets/firefox-sync.yaml;
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
                ${config.services.postgresql.package}/bin/pg_dump -Fc ${config.services.nextcloud.config.dbname} > /var/lib/nextcloud/nextcloud-dbdump.bak
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
                ${config.services.mysql.package}/bin/mysqldump ${config.services.firefly-iii.settings.DB_DATABASE} > /var/lib/firefly-iii/firefly.sql
            '';

            user = config.services.firefly-iii.user;
            
            timerConfig = {
                OnCalendar = "05:00"; # every day at 5am
                Persistent = true;
            };
        };
    };

    nixpkgs.config.permittedInsecurePackages = [
        "nextcloud-27.1.11"
    ]; # can't be bothered to upgrade

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

    # services.seafile = {
    #     enable = true;
    #     seafileSettings = {
    #         fileserver.host = "0.0.0.0";
    #     };
    #     adminEmail = "thomas@hexf.me";
    #     initialAdminPassword = "hexf1234";
    #     ccnetSettings = {
    #         General.SERVICE_URL = "https://seafile.${tailnet}";
    #     };
    # };

    services.postgresql.package = pkgs.postgresql_16;
    # accept to nextcloud on 8001
    services.nginx.virtualHosts.${config.services.nextcloud.hostName}.listen = [{port = 8001; addr="127.0.0.1";}];

    # we need bleeding-edge tailscale for
    # https://github.com/tailscale/tailscale/commit/dc1d8826a2a16deda51ce20ef12bb31e1421bb97
    # so firefly wont commit CSP violation
    services.tailscale.package = pkgs.unstable.tailscale;

    services.firefly-iii = {
        enable = true;
        group = "nginx";

        settings = {
            APP_URL = "https://firefly.${tailnet}";
            APP_KEY_FILE = config.sops.secrets.firefly_appkey.path;
            USE_PROXIES = "127.0.0.1";
            TRUSTED_PROXIES = "**";
            TZ = "Pacific/Auckland";
            DB_CONNECTION = "mysql";  
            DB_DATABASE = "firefly";
            DB_USERNAME = config.services.firefly-iii.user;
        };

        virtualHost = "firefly.${tailnet}";
        enableNginx = true;
    };

    services.nginx.virtualHosts.${config.services.firefly-iii.virtualHost}.listen = [{port = 8002; addr="127.0.0.1";}];

    services.mysql = {
      enable = true;
      package = pkgs.mariadb;
      ensureDatabases = [ "${config.services.firefly-iii.settings.DB_DATABASE}" ];
      ensureUsers = [
        {
          name = config.services.firefly-iii.user;
          ensurePermissions = { "${config.services.firefly-iii.settings.DB_DATABASE}.*" = "ALL PRIVILEGES"; };
        }
      ];
    };

    # akahu-firefly link
    systemd.services.akahu-firefly = {
      serviceConfig.Type = "oneshot";
      script = ''
        ${pkgs.nodejs}/bin/node ${akahu-firefly}/lib/node_modules/akahu-firefly ${config.sops.secrets."firefly_akahu_config.json".path}
      '';
    };

    # systemd.timers.akahu-firefly = {
    #     wantedBy = ["timers.target"];
    #     partOf = ["akahu-firefly.service"];
    #     timerConfig = {
    #         OnCalendar = "*:*:0";
    #         Unit = "akahu-firefly.service";
    #     };
    # };

    services.tailscale.expose = {
        enable = true;
        authKey = "file:/persist/tailscale-authkey"; #TODO - put in secrets
        dataDir = "/persist/tailscale-expose";
        services = {
            # seafile = {
            #     httpsRoutes = {"/" = "http://localhost:8000";};
            #     funnel = true;
            # };

            nextcloud = {
                httpsRoutes = {"/" = "http://localhost:8001";};
                funnel = true;
            };

            firefly = {
                httpsRoutes = {"/" = "http://localhost:8002";};
                funnel = true; # dont expose externally
            };

            jellyfin = {
                httpsRoutes = {"/" = "http://localhost:8096"; };
                funnel = true;
            };

            ombi = {
                httpsRoutes = {"/" = "http://localhost:${toString config.services.ombi.port}"; };
                funnel = true;
            };

            hass = {
                httpsRoutes = {"/" = "http://localhost:${toString config.services.home-assistant.config.http.server_port}"; };
                funnel = true;
            };

            # firefox-sync = {
            #     httpsRoutes = {"/" = "http://localhost:${toString config.services.firefox-syncserver.settings.port}"; };
            #     funnel = false; # require tailscale connection for sync
            # };
        };
    };

    # firefox-syncserver
    services.firefox-syncserver = {
        enable = false;
        logLevel = "info";
        database.createLocally = true;
        settings.tokenserver.enabled = true;

        singleNode = {
            enable = true;
            capacity = 1;
            hostname = "firefox-sync";
            url = "https://firefox-sync.fluffy-mercat.ts.net";
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
#    services.xserver.desktopManager.plasma5.enable = true;

    users.users.htpc = {
        isNormalUser  = true;
        description  = "HTPC user";
        extraGroups  = [ ];
    };

    services.xserver.displayManager.autoLogin.user = "htpc";
    networking.networkmanager.enable = lib.mkForce false;

    # oculus rift cv1!
#    boot.kernelParams = [ "intel_iommu=on" "vfio-pci.ids=8086:56a1,8086:4f90,8086:7a60" ]; # iommu
    boot.initrd.kernelModules = [
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"
      ];

    virtualisation.spiceUSBRedirection.enable = true;
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;


    # Home Assistant
    services.home-assistant = {
        enable = true;
        extraPackages = ps: with ps; [ psycopg2 ];
        config = {
            http = {
                server_host = "localhost";
                trusted_proxies = ["127.0.0.1" "::1"];
                use_x_forwarded_for = true;
            };
            auth_header = {
                username_header = "Tailscale-User-Login";
                debug = true;
            };
            recorder.db_url = "postgresql://@/hass";
            mobile_app = {};
            history = {};

            default_config = {}; 

            "automation ui" = "!include automations.yaml";
            "scene ui" = "!include scenes.yaml";
            "script ui" = "!include scripts.yaml";
        };
        lovelaceConfig = null;
        extraComponents = [
            "analytics"
            "google_translate"
            "met"
            "radio_browser"
            "shopping_list"
            "default_config"
            "tuya"
            "generic_thermostat"
            "mikrotik"
            "frank_energy"
        ];
        customComponents = with pkgs.home-assistant-custom-components; [
            auth-header
            (
                buildHomeAssistantComponent rec {
                    owner = "brunsy";
                    domain = "frank_energy";
                    version = "0.0.4";

                    src = fetchFromGitHub {
                        owner = "brunsy";
                        repo = "ha-frankenergy";
                        tag = "v${version}";
                        hash = "sha256-1veZkn4mQ9pIWx7GSleCCNCAHTADYTgMyGm2qSJkZP4=";
                    };

                    dependencies = [
                        aiohttp
                    ];
                }
            )
        ];
    };

    services.postgresql = {
        enable = true;
        ensureDatabases = ["hass"];
        ensureUsers = [{
            name = "hass";
            ensureDBOwnership = true;
        }];
    };


}
