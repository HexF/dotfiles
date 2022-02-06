{ config, pkgs, ... }: {

    imports = [
        ../modules/base.nix
        ../modules/bios.nix
        ../modules/server.nix

        ./modules/media-server.nix

        ./hardware-configuration.nix
    ];

    
    networking.interfaces.ens192.useDHCP = true;
    networking.hostName = "hydroxide";


    services.nginx = {
        enable = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedProxySettings = true;
        virtualHosts = {
            "git.hexdev.nz" = {
                locations."/".proxyPass = "http://localhost:8092/";   # Proxy Gitea
            };
        };    
    };

    services.media-server = {
        enable = true;
        jellyfin.enable = true;
        sonarr.enable = true;
        radarr.enable = true;
        jackett.enable = true;
        lidarr.enable = true;
        navidrome.enable = true;

        vhostSuffix = ".oh.hexf.me";
    };

    services.gitea = {
        enable = true;
        appName = "HexDev: Gitea";
        database = {
            type = "postgres";
            password = "postgres gitea password";
        };
        domain = "git.hexdev.nz";
        rootUrl = "https://git.hexdev.nz";
        httpPort = 8092;
        settings = {
            repository = {
                ROOT = "/mnt/src/repo";
            };
            service = {
                DISABLE_REGISTRATION = true;
            };
        };
    };

    services.postgresql = {
        enable = true;
        authentication = ''
            local gitea all ident map=gitea-users
        '';
        identMap = ''
            gitea-users gitea gitea
        '';
    };

    fileSystems."/mnt/media" = {
        device = "192.168.1.101:/volume2/Media";
        fsType = "nfs";
    };

    fileSystems."/mnt/src" = {
        device = "192.168.1.101:/volume2/\"Thomas Source Code\"";
        fsType = "nfs";
    };


    users.users.turbotylar = {
        isNormalUser = true;
        extraGroups = [ ];
        shell = pkgs.zsh;
    };

    

    networking.firewall.allowedTCPPorts = [ 3000 80 ];
}