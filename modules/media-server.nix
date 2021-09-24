# Simple Jellyfin, Transmission, Jackett, Sonarr and Radarr configuration

{config, lib, pkgs, ...}:
with lib;

let
    cfg = config.services.media-server;
    transmissionActivationScript = ''
        install -d -m 700 '${config.services.transmission.home}/.config/transmission-daemon'
        chown -R '${config.services.transmission.user}:${config.services.transmission.group}' ${config.services.transmission.home}/.config/transmission-daemon
        install -d -m '${config.services.transmission.downloadDirPermissions}' -o '${cfg.user}' -g '${cfg.group}' '${config.services.transmission.settings.download-dir}'
        '' + optionalString config.services.transmission.settings.incomplete-dir-enabled ''
        install -d -m '${config.services.transmission.downloadDirPermissions}' -o '${cfg.user}' -g '${cfg.group}' '${config.services.transmission.settings.incomplete-dir}'
        '' + optionalString config.services.transmission.settings.watch-dir-enabled ''
        install -d -m '${config.services.transmission.downloadDirPermissions}' -o '${cfg.user}' -g '${cfg.group}' '${config.services.transmission.settings.watch-dir}'
        '';
    nginxProxyVhostConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
    '';
    nginxAuthVhostConfig = ''
        auth_pam "Secure Area";
        auth_pam_service_name "nginx_media";
    '';
in {
    options = {
        services.media-server = {
            enable = mkOption {
                default = false;
            };

            user = mkOption {
                default = "media";
            };

            group = mkOption {
                default = "media";
            };

            vhostSuffix = mkOption {
                #e.g. jellyfin.localhost
                default = ".localhost";
            };

            jellyfin = {
                enable = mkOption {
                    default = false;
                };

                package = mkOption {
                    default = pkgs.jellyfin;
                };
            };

            transmission = {
                enable = mkOption {
                    default = false;
                };

                dataDir = mkOption {
                    default = "/var/lib/transmission/";
                };        
            };

            sonarr = {
                enable = mkOption {
                    default = false;
                };          
            }; 

            radarr = {
                enable = mkOption {
                    default = false;
                };          
            }; 

            jackett = {
                enable = mkOption {
                    default = false;
                };              
            }; 



        };
    };

    config = mkIf cfg.enable {

        services.jellyfin = {
            enable = cfg.jellyfin.enable;
            user = cfg.user;
            group = cfg.group;
            package = cfg.jellyfin.package;

            # Open the ports, although we will also add virtualhosts to nginx
            openFirewall = true;
        };

        services.transmission = {
            enable = cfg.transmission.enable;
            user = cfg.user;
            group = cfg.group;

            settings."rpc-bind-address" = "0.0.0.0";
            settings."watch-dir-enabled" = true;
            settings."rpc-host-whitelist" = "transmission${cfg.vhostSuffix}";
            settings."incomplete-dir" = "${cfg.transmission.dataDir}IncompleteDownloads";
            settings."download-dir" = "${cfg.transmission.dataDir}Downloads";

            openFirewall = true;   
        };

        systemd.services.transmission-trackers = {
            serviceConfig.Type = "oneshot";
            script = ''
            ${pkgs.curl}/bin/curl https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt | ${pkgs.findutils}/bin/xargs -I % ${pkgs.transmission}/bin/transmission-remote -t all -td %
            '';
        };

        systemd.timers.transmission-trackers = {
            wantedBy = [ "timers.target" ];
            partOf = [ "transmission-trackers.service" ];
            timerConfig.OnCalendar = [ "*-*-* *:*:00" ];
        };

        services.sonarr = {
            enable = cfg.sonarr.enable;
            user = cfg.user;
            group = cfg.group;

            openFirewall = true;   
        };

        services.radarr = {
            enable = cfg.radarr.enable;
            user = cfg.user;
            group = cfg.group;

            openFirewall = true;   
        };

        services.jackett = {
            enable = cfg.jackett.enable;
            user = cfg.user;
            group = cfg.group;


            openFirewall = true;   
        };

        security.pam.services.nginx.setEnvironment = false;
        systemd.services.nginx.serviceConfig = {
            SupplementaryGroups = [ "shadow" ];
            NoNewPrivileges = lib.mkForce false;
            PrivateDevices = lib.mkForce false;
            ProtectHostname = lib.mkForce false;
            ProtectKernelTunables = lib.mkForce false;
            ProtectKernelModules = lib.mkForce false;
            RestrictAddressFamilies = lib.mkForce [ ];
            LockPersonality = lib.mkForce false;
            MemoryDenyWriteExecute = lib.mkForce false;
            RestrictRealtime = lib.mkForce false;
            RestrictSUIDSGID = lib.mkForce false;
            SystemCallArchitectures = lib.mkForce "";
            ProtectClock = lib.mkForce false;
            ProtectKernelLogs = lib.mkForce false;
            RestrictNamespaces = lib.mkForce false;
            SystemCallFilter = lib.mkForce "";
        };

        services.nginx.additionalModules = [ pkgs.nginxModules.pam ];
        services.nginx.virtualHosts = {
            "jellyfin${cfg.vhostSuffix}" = mkIf cfg.jellyfin.enable {
                serverAliases = [ "jellyfin" ];
                locations."/".extraConfig = ''
                    proxy_pass http://127.0.0.1:8096;
                '' + nginxProxyVhostConfig;
            };

            "transmission${cfg.vhostSuffix}" = mkIf cfg.transmission.enable {
                serverAliases = [ "transmission" ];
                locations."/".extraConfig = ''
                    proxy_pass http://127.0.0.1:9091;
                '' + nginxProxyVhostConfig + nginxAuthVhostConfig;
            };

            "sonarr${cfg.vhostSuffix}" = mkIf cfg.sonarr.enable {
                serverAliases = [ "sonarr" ];
                locations."/".extraConfig = ''
                    proxy_pass http://127.0.0.1:8989;
                '' + nginxProxyVhostConfig + nginxAuthVhostConfig;
            };

            "radarr${cfg.vhostSuffix}" = mkIf cfg.radarr.enable {
                serverAliases = [ "radarr" ];
                locations."/".extraConfig = ''
                    proxy_pass http://127.0.0.1:7878;
                '' + nginxProxyVhostConfig + nginxAuthVhostConfig;
            };

            "jackett${cfg.vhostSuffix}" = mkIf cfg.jackett.enable {
                serverAliases = [ "jackett" ];
                locations."/".extraConfig = ''
                    proxy_pass http://127.0.0.1:9117;
                '' + nginxProxyVhostConfig + nginxAuthVhostConfig;
            };

            
        };

        

        security.pam.services.nginx_media = {
            name = "nginx_media";
            unixAuth = true;
        };


        # hacky workaround for transmission watch dir
        system.activationScripts.transmission-daemon = mkForce transmissionActivationScript;

        users.users = mkIf (cfg.user == "media") {
            media = {
                group = cfg.group;
                isSystemUser = true;
            };
        };

        users.groups = mkIf (cfg.group == "media") {
            media = {};
        };
    };


}
