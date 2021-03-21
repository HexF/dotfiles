# Server for hydra
{ config, pkgs, ... }: {

    networking.interfaces.ens192.useDHCP = true;
    networking.hostName = "hydroxide";

    services.hydra = {
        enable = true;
        hydraURL = "https://hydra.hexf.me"; # externally visible URL
        notificationSender = "hydra@localhost"; # e-mail of hydra service
        # a standalone hydra will require you to unset the buildMachinesFiles list to avoid using a nonexistant /etc/nix/machines
        buildMachinesFiles = [];
        # you will probably also want, otherwise *everything* will be built from scratch
        useSubstitutes = true;
    };

    networking.firewall.allowedTCPPorts = [ 3000 ];
}