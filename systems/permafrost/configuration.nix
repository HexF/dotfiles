{ config, pkgs, ... }: {

    imports = [
        ../modules/base.nix
        ../modules/efi.nix
        ../modules/server.nix

        ../modules/media-server.nix

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


    services.media-server = {
        enable = true;
        jellyfin.enable = true;
        sonarr.enable = true;
        radarr.enable = true;
        jackett.enable = true;
        lidarr.enable = true;
        navidrome.enable = true;
        unmanic.enable = true;

        vhostSuffix = ".pf.hexf.me";
    };    

    networking.firewall.allowedTCPPorts = [ 3000 80 ];
}