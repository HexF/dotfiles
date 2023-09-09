{ config, pkgs, ... }: let
    tailnet = "fluffy-mercat.ts.net";
in {

    imports = [
        ../modules/base.nix
        ../modules/efi.nix
        ../modules/server.nix

        ../modules/media-server.nix
        ../modules/tailscale-expose.nix

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
        enableBrokenCiphersForSSE = false;
    };
    # accept to nextcloud on 8001
    services.nginx.virtualHosts.${config.services.nextcloud.hostName}.listen = [{port = 8001; addr="127.0.0.1";}];

    services.tailscale.expose = {
        enable = true;
        authKey = "file:/persist/tailscale-authkey"; #TODO - put in secrets
        dataDir = "/persist/tailscale-expose";
        services = {
            nextcloud = {
                httpsRoutes = {"/" = "http://localhost:8001";};
                funnel = true;
            };
        };
    };


    services.media-server = {
        enable = true;
        jellyfin.enable = true;
        sonarr.enable = true;
        radarr.enable = true;
        jackett.enable = true;
        # lidarr.enable = true;
        # navidrome.enable = true;
        # unmanic.enable = true;

        vhostSuffix = ".pf.hexf.me";
    };    

    networking.firewall.allowedTCPPorts = [ 3000 80 ];
}