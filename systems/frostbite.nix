{ config, pkgs, ... }:

{
    networking.interfaces.enp0s20f0u2c2.useDHCP = true;
    networking.interfaces.enp0s31f6.useDHCP = true;
    networking.interfaces.wlp3s0.useDHCP = true;
    networking.hostName = "frostbite";

    networking.wireless.interfaces = ["wlp3s0"];
    

    boot.kernelParams = [ "intel_pstate=active" ];

    services.xserver = {
        videoDrivers = [ "nvidia" ];
        synaptics.enable = true;
    };

    users.groups.plugdev = {};
    users.users.thobson.extraGroups = [ "docker" "plugdev" "dialout" "wheel" ]; 
    # wheel is required for wpa_gui/wpa_cli

    environment.systemPackages = with pkgs; [
        wget
        texlive.combined.scheme-full
        docker-compose
        piper
    ];

    virtualisation.docker.enable = true;

    networking.firewall.allowedTCPPorts = [ 3000 ];
}