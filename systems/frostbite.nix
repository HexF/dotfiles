{ config, pkgs, ... }:

{
    networking.interfaces.enp0s20f0u2c2.useDHCP = true;
    networking.interfaces.enp0s31f6.useDHCP = true;
    networking.interfaces.wlp3s0.useDHCP = true;
    networking.hostname = "frostbite";

    boot.kernelParams = [ "intel_pstate=active" ];

    services.xserver = {
        videoDrivers = [ "nvidia" ];
    };

    users.groups.plugdev = {};
    users.users.thobson.extraGroups = [ "docker" "plugdev" "dialout" ]; 

    environment.systemPackages = with pkgs; [
        wget
        texlive.combined.scheme-full
        docker-compose
        piper
    ];

    virtualisation.docker.enable = true;

    networking.firewall.allowedTCPPorts = [ 3000 ];
}