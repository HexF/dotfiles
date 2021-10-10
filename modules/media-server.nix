# Simple Jellyfin, Transmission, Jackett, Sonarr and Radarr configuration

{config, lib, pkgs, ...}:
with lib;

let
    cfg = config.services.media-server;
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

            lidarr = {
                enable = mkOption {
                    default = false;
                };          
            }; 

            jackett = {
                enable = mkOption {
                    default = false;
                };              
            }; 

            airsonic = {
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

        services.airsonic = {
            enable = cfg.airsonic.enable;
            user = cfg.user;
            group = cfg.group;

            virtualHost = "airsonic${cfg.vhostSuffix}";
        };

        services.lidarr = {
            enable = cfg.lidarr.enable;
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

        services.nginx = {
            enable = true;
            additionalModules = [ pkgs.nginxModules.pam ];
            virtualHosts = {
                "jellyfin${cfg.vhostSuffix}" = mkIf cfg.jellyfin.enable {
                    serverAliases = [ "jellyfin" ];
                    locations."/".proxyPass = "http://127.0.0.1:8096";
                    locations."/socket" = {
                        proxyPass = "http://127.0.0.1:8096";
                        proxyWebsockets = true;
                    };
                };

                "transmission${cfg.vhostSuffix}" = mkIf cfg.transmission.enable {
                    serverAliases = [ "transmission" ];
                    locations."/" = {
                        proxyPass = "http://127.0.0.1:9091";
                        extraConfig = nginxAuthVhostConfig;
                    };
                };

                "sonarr${cfg.vhostSuffix}" = mkIf cfg.sonarr.enable {
                    serverAliases = [ "sonarr" ];
                    locations."/" = {
                        proxyPass = "http://127.0.0.1:8989";
                        extraConfig = nginxAuthVhostConfig;
                    };
                };

                "radarr${cfg.vhostSuffix}" = mkIf cfg.radarr.enable {
                    serverAliases = [ "radarr" ];
                    locations."/" = {
                        proxyPass = "http://127.0.0.1:7878";
                        extraConfig = nginxAuthVhostConfig;
                    };
                };

                "lidarr${cfg.vhostSuffix}" = mkIf cfg.lidarr.enable {
                    serverAliases = [ "lidarr" ];
                    locations."/" = {
                        proxyPass = "http://127.0.0.1:8686";
                        extraConfig = nginxAuthVhostConfig;
                    };
                };

                "jackett${cfg.vhostSuffix}" = mkIf cfg.jackett.enable {
                    serverAliases = [ "jackett" ];
                    locations."/" = {
                        proxyPass = "http://127.0.0.1:9117";
                        extraConfig = nginxAuthVhostConfig;
                    };
                };  
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
