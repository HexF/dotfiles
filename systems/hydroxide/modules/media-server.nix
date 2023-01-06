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

            navidrome = {
                enable = mkOption {
                    default = false;
                };
            };

            unmanic = {
                enable = mkOption {
                    default = false;
                };

                package = mkOption {
                    default = (callPackage ../../../packages/unmanic {
                        peewee_migrate = (callPackage ../../../packages/peewee_migrate {});
                        swagger_ui_py = (callPackage ../../../packages/swagger_ui_py {});
                    });
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

        systemd.services.unmanic = mkIf cfg.unmanic.enable {
            description = "Unmanic Library Organizer";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];

            serviceConfig = {
                DynamicUser = true;
            };

            Environment="HOME_DIR=/var/lib/unmanic";
            StateDirectory = "unmanic";
            WorkingDirectory = "/var/lib/unmanic";
            RuntimeDirectory = "unmanic";
            RootDirectory = "/run/unmanic";
            ReadWritePaths = "";
            BindReadOnlyPaths = [
                builtins.storeDir
                "/mnt/media/"
            ];

            CapabilityBoundingSet = "";
            RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
            RestrictNamespaces = true;
            PrivateDevices = true;
            PrivateUsers = true;
            ProtectClock = true;
            ProtectControlGroups = true;
            ProtectHome = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            SystemCallArchitectures = "native";
            SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
            RestrictRealtime = true;
            LockPersonality = true;
            MemoryDenyWriteExecute = true;
            UMask = "0066";
            ProtectHostname = true;
        }

        systemd.services.navidrome = mkIf cfg.navidrome.enable {
            description = "Navidrome Media Server";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
                ExecStart = ''
                ${pkgs.navidrome}/bin/navidrome --configfile ${(pkgs.formats.json {}).generate "navidrome.json" {
                    Address = "127.0.0.1";
                    Port = 4533;
                    MusicFolder = "/mnt/media/music";
                }}
                '';
                DynamicUser = true;
                StateDirectory = "navidrome";
                WorkingDirectory = "/var/lib/navidrome";
                RuntimeDirectory = "navidrome";
                RootDirectory = "/run/navidrome";
                ReadWritePaths = "";
                BindReadOnlyPaths = [
                    builtins.storeDir
                    "/mnt/media/music"
                ];
                CapabilityBoundingSet = "";
                RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
                RestrictNamespaces = true;
                PrivateDevices = true;
                PrivateUsers = true;
                ProtectClock = true;
                ProtectControlGroups = true;
                ProtectHome = true;
                ProtectKernelLogs = true;
                ProtectKernelModules = true;
                ProtectKernelTunables = true;
                SystemCallArchitectures = "native";
                SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
                RestrictRealtime = true;
                LockPersonality = true;
                MemoryDenyWriteExecute = true;
                UMask = "0066";
                ProtectHostname = true;
            };
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

                "sonarr${cfg.vhostSuffix}" = mkIf cfg.sonarr.enable {
                    serverAliases = [ "sonarr" ];
                    locations."/" = {
                        proxyPass = "http://127.0.0.1:8989";
                        extraConfig = nginxAuthVhostConfig;
                    };
                };

                "unmanic${cfg.vhostSuffix}" = mkIf cfg.unmanic.enable {
                    serverAliases = [ "unmanic" ];
                    locations."/" = {
                        proxyPass = "http://127.0.0.1:8888";
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

                "navidrome${cfg.vhostSuffix}" = mkIf cfg.navidrome.enable {
                    serverAliases = [ "navidrome" ];
                    locations."/" = {
                        proxyPass = "http://127.0.0.1:4533";
                    };
                };
            };

        };

        security.pam.services.nginx_media = {
            name = "nginx_media";
            unixAuth = true;
        };

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
