{ config, pkgs, ... }:
{

    # Enable virtualization and virt-manager
    virtualisation.libvirtd.enable = true;
    programs.dconf.enable = true;
    environment.systemPackages = with pkgs; [
        virt-manager
        freerdp # Allow us to connect
    ];


    # Allow us to use virt-manager
    users.users.thobson.extraGroups = ["libvirtd"];

}