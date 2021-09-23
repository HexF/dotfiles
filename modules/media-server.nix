# Simple Jellyfin, Transmission, Jackett, Sonarr and Radarr configuration

{config, lib, pkgs, ...}:
with lib;

let
    cfg = config.services.media-server;
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

        services.nginx.virtualHosts = {
            "jellyfin${cfg.vhostSuffix}" = mkIf cfg.jellyfin.enable {
                serverAliases = [ "jellyfin" ];
                locations."/".extraConfig = ''
                    proxy_pass http://127.0.0.1:8096;
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_http_version 1.1;
                    proxy_set_header Upgrade $http_upgrade;
                    proxy_set_header Connection "Upgrade";
                '';
            };

            "transmission${cfg.vhostSuffix}" = mkIf cfg.transmission.enable {
                serverAliases = [ "transmission" ];
                locations."/".extraConfig = ''
                    proxy_pass http://127.0.0.1:9091;
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_http_version 1.1;
                    proxy_set_header Upgrade $http_upgrade;
                    proxy_set_header Connection "Upgrade";
                '';
            };

            "sonarr${cfg.vhostSuffix}" = mkIf cfg.sonarr.enable {
                serverAliases = [ "sonarr" ];
                locations."/".extraConfig = ''
                    proxy_pass http://127.0.0.1:8989;
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_http_version 1.1;
                    proxy_set_header Upgrade $http_upgrade;
                    proxy_set_header Connection "Upgrade";
                '';
            };

            "radarr${cfg.vhostSuffix}" = mkIf cfg.radarr.enable {
                serverAliases = [ "radarr" ];
                locations."/".extraConfig = ''
                    proxy_pass http://127.0.0.1:7878;
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_http_version 1.1;
                    proxy_set_header Upgrade $http_upgrade;
                    proxy_set_header Connection "Upgrade";
                '';
            };

            "jackett${cfg.vhostSuffix}" = mkIf cfg.jackett.enable {
                serverAliases = [ "jackett" ];
                locations."/".extraConfig = ''
                    proxy_pass http://127.0.0.1:9117;
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_http_version 1.1;
                    proxy_set_header Upgrade $http_upgrade;
                    proxy_set_header Connection "Upgrade";
                '';
            };

            
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
