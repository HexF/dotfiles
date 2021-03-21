# Server for hydra
{ config, pkgs, ... }: {

    networking.interfaces.ens192.useDHCP = true;
}